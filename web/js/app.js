/** @typedef {{ id: number, lit: boolean, out: boolean, el: HTMLElement }} CandleState */

const els = {
  candles: document.getElementById("candles"),
  status: document.getElementById("status"),
  countRange: document.getElementById("candle-count"),
  countOut: document.getElementById("count-out"),
  ageInput: document.getElementById("age-input"),
  modeCount: document.querySelector(".mode-count"),
  modeDigits: document.querySelector(".mode-digits"),
  segs: document.querySelectorAll(".seg"),
  btnLight: document.getElementById("btn-light"),
  btnReset: document.getElementById("btn-reset"),
  btnMic: document.getElementById("btn-mic"),
  musicToggle: document.getElementById("music-toggle"),
  meterWrap: document.getElementById("meter-wrap"),
  meterFill: document.getElementById("meter-fill"),
  celebration: document.getElementById("celebration"),
  fxCanvas: document.getElementById("fx-canvas"),
};

/** @type {"count" | "digits"} */
let mode = "count";
/** @type {CandleState[]} */
let candles = [];
let nextId = 0;
let micActive = false;
let celebrated = false;

// --- Audio: music + blow detection ---
let audioCtx = null;
/** @type {MediaStream | null} */
let micStream = null;
/** @type {AnalyserNode | null} */
let analyser = null;
let micRAF = 0;
/** @type {(() => void) | null} */
let musicStop = null;

const BLOW_THRESHOLD = 0.22;
const BLOW_HOLD_MS = 120;
let blowAccum = 0;
let lastMicTs = 0;

function ensureAudio() {
  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (audioCtx.state === "suspended") {
    audioCtx.resume();
  }
  return audioCtx;
}

const BIRTHDAY_NOTES = [
  { f: 392.0, d: 0.25 },
  { f: 392.0, d: 0.25 },
  { f: 440.0, d: 0.5 },
  { f: 392.0, d: 0.5 },
  { f: 523.25, d: 0.5 },
  { f: 493.88, d: 0.75 },
  { f: 392.0, d: 0.25 },
  { f: 392.0, d: 0.25 },
  { f: 440.0, d: 0.5 },
  { f: 392.0, d: 0.5 },
  { f: 587.33, d: 0.5 },
  { f: 523.25, d: 0.75 },
  { f: 392.0, d: 0.25 },
  { f: 392.0, d: 0.25 },
  { f: 783.99, d: 0.5 },
  { f: 659.25, d: 0.5 },
  { f: 523.25, d: 0.5 },
  { f: 493.88, d: 0.5 },
  { f: 440.0, d: 0.5 },
  { f: 440.0, d: 0.25 },
  { f: 440.0, d: 0.25 },
  { f: 493.88, d: 0.5 },
  { f: 493.88, d: 0.5 },
  { f: 440.0, d: 0.25 },
  { f: 493.88, d: 0.25 },
  { f: 523.25, d: 0.25 },
  { f: 587.33, d: 0.75 },
];

let musicLoopTimer = null;
let musicGeneration = 0;

/** Simple synthesized Happy Birthday melody (loop while toggle is on). */
function startBirthdayMusic() {
  stopBirthdayMusic();
  const gen = ++musicGeneration;

  const playPhrase = () => {
    if (gen !== musicGeneration || !els.musicToggle.checked) return;
    const ctx = ensureAudio();
    const gain = ctx.createGain();
    gain.gain.value = 0.12;
    gain.connect(ctx.destination);

    let t = ctx.currentTime + 0.05;
    let duration = 0;
    for (const n of BIRTHDAY_NOTES) {
      const osc = ctx.createOscillator();
      osc.type = "triangle";
      osc.frequency.value = n.f;
      osc.connect(gain);
      osc.start(t);
      osc.stop(t + n.d * 0.95);
      t += n.d;
      duration += n.d;
    }

    musicLoopTimer = window.setTimeout(playPhrase, duration * 1000 - 80);
  };

  playPhrase();
  musicStop = () => {
    musicGeneration += 1;
    if (musicLoopTimer) clearTimeout(musicLoopTimer);
    musicLoopTimer = null;
    musicStop = null;
  };
}

function stopBirthdayMusic() {
  if (musicStop) musicStop();
}

function syncMusic() {
  if (els.musicToggle.checked) {
    ensureAudio();
    startBirthdayMusic();
  } else {
    stopBirthdayMusic();
  }
}

// --- Candles UI ---
function getCandleSpecs() {
  if (mode === "digits") {
    const age = Math.min(99, Math.max(0, parseInt(els.ageInput.value, 10) || 0));
    const digits = age < 10 ? [age] : String(age).split("").map(Number);
    return digits.map((d) => ({ kind: "digit", label: String(d) }));
  }
  const n = parseInt(els.countRange.value, 10);
  return Array.from({ length: n }, () => ({ kind: "stick", label: "" }));
}

function renderCandles() {
  celebrated = false;
  els.celebration.classList.add("hidden");
  confetti.clear();

  const specs = getCandleSpecs();
  candles = [];
  nextId = 0;
  els.candles.innerHTML = "";

  specs.forEach((spec) => {
    const id = nextId++;
    const el = document.createElement("div");
    el.className = "candle" + (spec.kind === "digit" ? " digit" : "");
    el.role = "listitem";
    el.tabIndex = 0;
    el.dataset.id = String(id);

    el.innerHTML = `
      <div class="flame-wrap">
        <div class="smoke"></div>
        <div class="flame"><div class="flame-inner"></div></div>
      </div>
      <div class="wick"></div>
      <div class="stick">${spec.kind === "digit" ? spec.label : ""}</div>
    `;

    el.addEventListener("click", () => toggleLight(id));
    el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        toggleLight(id);
      }
    });

    els.candles.appendChild(el);
    candles.push({ id, lit: false, out: false, el });
  });

  updateStatus();
}

function candleById(id) {
  return candles.find((c) => c.id === id);
}

function lightCandle(c) {
  if (c.out || c.lit) return;
  c.lit = true;
  c.el.classList.add("lit");
}

function blowOutCandle(c) {
  if (!c.lit || c.out) return;
  c.lit = false;
  c.out = true;
  c.el.classList.remove("lit");
  c.el.classList.add("out", "just-out");
  window.setTimeout(() => c.el.classList.remove("just-out"), 1300);
}

function toggleLight(id) {
  ensureAudio();
  const c = candleById(id);
  if (!c || c.out) return;
  if (!c.lit) lightCandle(c);
  updateStatus();
  checkAllOut();
}

function lightAll() {
  ensureAudio();
  candles.forEach((c) => lightCandle(c));
  if (els.musicToggle.checked && !musicStop) syncMusic();
  updateStatus();
}

function updateStatus() {
  const lit = candles.filter((c) => c.lit).length;
  const total = candles.length;
  const out = candles.filter((c) => c.out).length;

  if (total === 0) {
    els.status.textContent = "请设置蜡烛数量";
    return;
  }
  if (out === total) {
    els.status.textContent = "全部熄灭啦！";
    return;
  }
  if (lit === 0) {
    els.status.textContent = "点击「点燃蜡烛」，或点单根蜡烛点火";
    return;
  }
  if (lit < total) {
    els.status.textContent = `已点燃 ${lit}/${total} 根，继续点蜡烛或一键点燃`;
    return;
  }
  els.status.textContent = micActive
    ? "对着麦克风吹气，吹灭蜡烛吧！"
    : "蜡烛都亮啦！开启「吹气」用麦克风吹灭";
}

function checkAllOut() {
  if (candles.length && candles.every((c) => c.out)) {
    if (!celebrated) {
      celebrated = true;
      triggerCelebration();
    }
  }
}

function blowOutOne() {
  const lit = candles.filter((c) => c.lit);
  if (!lit.length) return;
  blowOutCandle(lit[0]);
  updateStatus();
  checkAllOut();
}

// --- Mic ---
async function toggleMic() {
  if (micActive) {
    stopMic();
    return;
  }
  try {
    ensureAudio();
    micStream = await navigator.mediaDevices.getUserMedia({
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
      },
      video: false,
    });
    const ctx = ensureAudio();
    const src = ctx.createMediaStreamSource(micStream);
    analyser = ctx.createAnalyser();
    analyser.fftSize = 2048;
    analyser.smoothingTimeConstant = 0.4;
    src.connect(analyser);

    micActive = true;
    els.btnMic.textContent = "关闭吹气";
    els.btnMic.classList.add("mic-on");
    els.meterWrap.classList.remove("hidden");
    blowAccum = 0;
    lastMicTs = performance.now();
    micLoop();
    updateStatus();
  } catch (err) {
    console.error(err);
    els.status.textContent = "无法使用麦克风，请检查浏览器权限";
  }
}

function stopMic() {
  micActive = false;
  cancelAnimationFrame(micRAF);
  if (micStream) {
    micStream.getTracks().forEach((t) => t.stop());
    micStream = null;
  }
  analyser = null;
  els.btnMic.textContent = "开启吹气（麦克风）";
  els.btnMic.classList.remove("mic-on");
  els.meterWrap.classList.add("hidden");
  els.meterFill.style.width = "0%";
  updateStatus();
}

function micLoop() {
  if (!micActive || !analyser) return;
  const buf = new Float32Array(analyser.fftSize);
  analyser.getFloatTimeDomainData(buf);
  let sum = 0;
  for (let i = 0; i < buf.length; i++) sum += buf[i] * buf[i];
  const rms = Math.sqrt(sum / buf.length);
  const level = Math.min(1, rms * 4.5);
  els.meterFill.style.width = `${level * 100}%`;

  const now = performance.now();
  const dt = now - lastMicTs;
  lastMicTs = now;

  if (level >= BLOW_THRESHOLD && candles.some((c) => c.lit)) {
    blowAccum += dt;
    if (blowAccum >= BLOW_HOLD_MS) {
      blowAccum = 0;
      blowOutOne();
    }
  } else {
    blowAccum = Math.max(0, blowAccum - dt * 0.5);
  }

  micRAF = requestAnimationFrame(micLoop);
}

// --- Confetti / FX ---
const confetti = {
  particles: [],
  ctx: null,
  w: 0,
  h: 0,
  raf: 0,
  running: false,

  init() {
    this.ctx = els.fxCanvas.getContext("2d");
    this.resize();
    window.addEventListener("resize", () => this.resize());
  },

  resize() {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    this.w = window.innerWidth;
    this.h = window.innerHeight;
    els.fxCanvas.width = this.w * dpr;
    els.fxCanvas.height = this.h * dpr;
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  },

  clear() {
    this.particles = [];
    this.running = false;
    cancelAnimationFrame(this.raf);
    if (this.ctx) this.ctx.clearRect(0, 0, this.w, this.h);
  },

  burst(count = 120) {
    const colors = ["#ff6b9d", "#ffc857", "#7b61ff", "#6ee7b7", "#ff8c42", "#fff"];
    for (let i = 0; i < count; i++) {
      this.particles.push({
        x: this.w * (0.3 + Math.random() * 0.4),
        y: this.h * 0.35,
        vx: (Math.random() - 0.5) * 14,
        vy: -Math.random() * 12 - 4,
        rot: Math.random() * Math.PI,
        vr: (Math.random() - 0.5) * 0.2,
        size: 4 + Math.random() * 6,
        color: colors[(Math.random() * colors.length) | 0],
        life: 1,
      });
    }
    if (!this.running) {
      this.running = true;
      this.tick();
    }
  },

  tick() {
    if (!this.ctx) return;
    this.ctx.clearRect(0, 0, this.w, this.h);
    this.particles = this.particles.filter((p) => p.life > 0.02);

    for (const p of this.particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.35;
      p.vx *= 0.99;
      p.rot += p.vr;
      p.life *= 0.985;

      this.ctx.save();
      this.ctx.translate(p.x, p.y);
      this.ctx.rotate(p.rot);
      this.ctx.globalAlpha = p.life;
      this.ctx.fillStyle = p.color;
      this.ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.6);
      this.ctx.restore();
    }

    if (this.particles.length && this.running) {
      this.raf = requestAnimationFrame(() => this.tick());
    } else {
      this.running = false;
    }
  },
};

function triggerCelebration() {
  els.celebration.classList.remove("hidden");
  confetti.burst(160);
  window.setTimeout(() => confetti.burst(80), 400);
  stopBirthdayMusic();
}

// --- Mode & events ---
function setMode(m) {
  mode = m;
  els.segs.forEach((btn) => {
    const active = btn.dataset.mode === m;
    btn.classList.toggle("active", active);
    btn.setAttribute("aria-selected", active ? "true" : "false");
  });
  els.modeCount.classList.toggle("hidden", m !== "count");
  els.modeDigits.classList.toggle("hidden", m !== "digits");
  renderCandles();
}

els.segs.forEach((btn) => {
  btn.addEventListener("click", () => setMode(/** @type {"count"|"digits"} */ (btn.dataset.mode)));
});

els.countRange.addEventListener("input", () => {
  els.countOut.textContent = els.countRange.value;
  if (mode === "count") renderCandles();
});

els.ageInput.addEventListener("change", () => {
  if (mode === "digits") renderCandles();
});

els.btnLight.addEventListener("click", lightAll);
els.btnReset.addEventListener("click", () => renderCandles());
els.btnMic.addEventListener("click", toggleMic);

els.musicToggle.addEventListener("change", () => {
  ensureAudio();
  syncMusic();
});

document.addEventListener(
  "click",
  () => ensureAudio(),
  { once: true }
);

confetti.init();
setMode("count");
