import Delta from "quill-delta";
self.onmessage = (e) => {
  const { from, to } = e.data;
  postMessage({ success: true, result: new Delta(from).diff(new Delta(to)) });
};
