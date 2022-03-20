const punktChangeHandler = (index) => (event) => {
  data.punkter[index] = event.currentTarget.value;
};
console.log(bakgrund);
const skapaPunkt = (punkt, index) => {
  const element = document.createElement("div");
  const knapp = document.createElement("span");
  const p = document.createElement("input");
  p.value = punkt;
  p.onchange = punktChangeHandler(index);
  knapp.className = "material-icons";
  knapp.innerText = "remove";

  element.appendChild(p);
  element.appendChild(knapp);

  return element;
};

/*
 * Skapa punkterna som finns när sidan laddas
 */
const punktlista = document.getElementById("list");
data.punkter.forEach((punkt, index) => {
  const p = skapaPunkt(punkt, index);
  punktlista.append(p);
});

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
document.getElementById("valj-bild").onclick = () => {
  const url = document.getElementById("bild-value").value;
  document.getElementById("bild").src = url;
};

const resultat = document.getElementById("resultat");
resultat.innerText = JSON.stringify(data);

/*
 * skicka iväg datan
 */
document.getElementById("redigera").onsubmit = async (e) => {
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
