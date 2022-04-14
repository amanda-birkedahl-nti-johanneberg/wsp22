let button = document.querySelector("#openB");
button.addEventListener("click", showMenu);

let closeB = document.querySelector("#closeB");
closeB.addEventListener("click", showMenu);

function showMenu() {
  let menu = document.querySelector("#meny");
  menu.classList.toggle("show");
}
