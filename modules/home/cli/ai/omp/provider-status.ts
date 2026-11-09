import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { lookup } from "@oh-my-pi/pi-coding-agent/config/registry";
import { getPreset, type StatusLinePreset, type StatusLineSegmentId } from "@oh-my-pi/pi-tui/status-line";

export default async function (pi: ExtensionAPI) {
  // Configure before session_start: OMP attaches live UI settings listeners later.
  const settings = (await pi.pi.Settings.current)!;
  const presetSetting = lookup("statusLine.preset")!;
  const preset = presetSetting.get(settings) as StatusLinePreset;
  const layout = getPreset(preset);
  const leftSetting = lookup("statusLine.leftSegments")!;
  const rightSetting = lookup("statusLine.rightSegments")!;
  const left = [...(preset === "custom" ? leftSetting.get(settings) as StatusLineSegmentId[] : layout.leftSegments)];
  const right = preset === "custom" ? rightSetting.get(settings) as StatusLineSegmentId[] : layout.rightSegments;

  if (!left.includes("status") && !right.includes("status")) {
    left.splice(left.indexOf("model") + 1, 0, "status");
  }

  // Switching to custom must retain the original preset's segment options.
  const optionsSetting = lookup("statusLine.segmentOptions")!;
  const options = { ...optionsSetting.get(settings) };
  for (const [segment, defaults] of Object.entries(layout.segmentOptions ?? {})) {
    options[segment] = { ...defaults, ...options[segment] };
  }
  optionsSetting.override(settings, options);
  leftSetting.override(settings, left);
  rightSetting.override(settings, [...right]);
  presetSetting.override(settings, "custom");
  lookup("statusLine.showHookStatus")!.override(settings, false);

  let stopTimer: (() => void) | undefined;
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    stopTimer?.();

    let previousProvider: string | undefined;
    const update = () => {
      const provider = ctx.models.current()?.provider;
      if (provider === previousProvider) return;
      previousProvider = provider;
      ctx.ui.setStatus("provider", provider ? `[${provider}]` : undefined);
    };
    update();
    // The live model query also catches idle /model switches and retry fallbacks.
    const timer = ctx.setInterval(update, 500);
    stopTimer = () => ctx.clearTimer(timer);
  });
}
