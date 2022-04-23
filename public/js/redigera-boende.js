const punktChangeHandler = (index) => (event) => {
  data.punkter[index] = event.currentTarget.value;
};

const removePunktHandler = (index) => () => {
  const punkter = data.punkter.filter((p) => data.punkter.indexOf(p) !== index);
  data.punkter = punkter;
  skapaPunktList(punkter);
  console.log("remove");
};

const skapaPunkt = (punkt, index) => {
  const li = document.createElement("li");
  const element = document.createElement("div");

  element.className = "flex items-center gap-2";

  const knapp = document.createElement("div");
  const p = document.createElement("input");
  p.value = punkt;
  p.onchange = punktChangeHandler(index);

  knapp.className = "material-icons bg-white select-none cursor-pointer";
  knapp.innerText = "remove";

  knapp.onclick = removePunktHandler(index);

  element.appendChild(p);
  element.appendChild(knapp);

  li.appendChild(element);

  return li;
};
const punktlista = document.getElementById("list");

/*
 * Skapa punkterna som finns när sidan laddas
 */
const skapaPunktList = (punkter) => {
  // återställ listan
  punktlista.innerHTML = "";
  punkter.forEach((punkt, index) => {
    const p = skapaPunkt(punkt, index);
    punktlista.append(p);
  });
};

skapaPunktList(data.punkter);

/*
 * Lyssna på när användaren skapar nya punkter
 */
document.getElementById("add-list").onclick = () => {
  const punkt = skapaPunkt("", data.punkter.length);
  data.punkter.push("");
  punktlista.append(punkt);
};

/*
 * Hantera färg
 */
const huvuddel = document.getElementById("huvuddel");
document.getElementById("valj-farg").oninput = (e) => {
  huvuddel.style.backgroundColor = e.currentTarget.value;
};

document.getElementById("reset").onclick = (e) => {
  e.preventDefault();
  document.getElementById("valj-farg").value = bakgrund;
  huvuddel.style.backgroundColor = bakgrund;
};

/*
 * Hantera bilden
 */
document.getElementById("valj-bild").onclick = (event) => {
  event.preventDefault()

  const url = document.getElementById("bild-value").value;
  document.getElementById("bild").src = url;
  data.bild = url
};
console.log("form");

/*
 * skicka iväg datan
 */
const form = document.getElementById("redigera");
form.onsubmit = async (e) => {
  e.preventDefault();

  data.bakgrund = huvuddel.style.backgroundColor;
  data.beskrivning = document.getElementById("beskrivning").value;

  const res = await fetch(`/boende/${data.id}/redigera`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (res.redirected) {
    window.location.href = res.url;
  }
};
