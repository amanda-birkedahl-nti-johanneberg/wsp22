const picker = document.getElementById("valj-farg");
const imagePicker = document.getElementById("valj-bild");
const bild = document.getElementById("bild");
const imageField = document.getElementById("bild-value");
const editRoom = document.getElementById("edit-room");
const aterstall = document.getElementById("reset");
const punktlista = document.getElementById("list");
const nyPunkt = document.getElementById("add-list");

const huvuddel = document.getElementById("huvuddel");

const punktChangeHandler = (index) => (event) => {
  data.punkter[index] = event.currentTarget.value;
};

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

data.punkter.forEach((punkt, index) => {
  const p = skapaPunkt(punkt, index);
  punktlista.append(p);
});

nyPunkt.onclick = () => {
  const punkt = skapaPunkt("", data.punkter.length);
  punktlista.append(punkt);
};

const uppdateraFarg = (e) => {
  huvuddel.style.backgroundColor = e.currentTarget.value;
};

imagePicker.onclick = () => {
  const url = imageField.value;
  console.log(url);
  bild.src = url;
};

aterstall.onclick = (e) => {
  e.preventDefault();
  picker.value = "#{rum[:bakgrund]}";
  huvuddel.style.backgroundColor = "#{rum[:bakgrund]}";
};

picker.oninput = uppdateraFarg;
editRoom.onsubmit = (e) => {
  e.preventDefault();
  console.log(data);
  fetch(`/boende/${data.id}/redigera`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
};
