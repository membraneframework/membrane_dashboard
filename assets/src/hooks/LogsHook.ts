import { ViewHookInterface } from "phoenix_live_view";

type Hook = ViewHookInterface & {
  attachOnClickCallbacks: (this: Hook) => void;
  spans: HTMLSpanElement[];
};

const LogsHook = {
  mounted(this: Hook) {
    this.spans = [];

    this.attachOnClickCallbacks();
  },
  updated(this: Hook) {
    this.attachOnClickCallbacks();
  },
  attachOnClickCallbacks(this: Hook) {
    // reset existing spans
    this.spans.forEach((span) => (span.onclick = null));
    this.spans = [];

    const pathTooltips = this.el.querySelectorAll("[data-type='tooltip']");

    // each PATH tooltip consist of a top div element with 2 nested spans
    // the first span is just 'PATH' string while the second one contains
    // the actual element's path
    pathTooltips.forEach((tooltip) => {
      const pathSpan = tooltip.children.item(1) as HTMLSpanElement;
      pathSpan.onclick = () =>
        this.pushEvent("dagre:focus:path", {
          path: pathSpan.textContent?.trim().split("/"),
        });

      this.spans.push(pathSpan);
    });
  },
};

export default LogsHook;
