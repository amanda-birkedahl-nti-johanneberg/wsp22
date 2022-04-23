let button = document.querySelector("#openB");
button.addEventListener("click", showMenu);

function showMenu() {
  let menu = document.querySelector("#meny");
  menu.classList.toggle("show");
}
