const colors = [
  "#E74C3C",
  "#3498DB",
  "#2ECC71",
  "#F1C40F",
  "#9B59B6",
  "#E67E22"
];

module.exports = () => {
  return colors[Math.floor(Math.random() * colors.length)];
};
