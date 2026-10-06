// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";

document.addEventListener("click", (event) => {
  const removeButton = event.target.closest("[data-remove-departure]");

  if (!removeButton) {
    return;
  }

  const departure = removeButton.closest("[data-departure]");

  if (!departure) {
    return;
  }

  const destroyField = departure.querySelector('input[name$="[_destroy]"]');

  if (destroyField) {
    destroyField.value = "1";
    departure.style.display = "none";
  } else {
    departure.remove();
  }
});

document.addEventListener("turbo:load", () => {
  const departuresContainer = document.querySelector("[data-departures-container]");
  const addDepartureButton = document.querySelector("[data-add-departure]");
  const departureTemplate = document.querySelector("[data-departure-template]");

  if (!departuresContainer || !addDepartureButton || !departureTemplate) {
    return;
  }

  addDepartureButton.addEventListener("click", () => {
    const uniqueIndex = Date.now().toString();
    const html = departureTemplate.innerHTML.replaceAll("NEW_RECORD", uniqueIndex);

    departuresContainer.insertAdjacentHTML("beforeend", html);
  });
});
