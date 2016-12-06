const debounceTimer = {};

export default function (key, fn, delay) {
  clearTimeout(debounceTimer[key]);
  debounceTimer[key] = setTimeout(fn, delay);
};
