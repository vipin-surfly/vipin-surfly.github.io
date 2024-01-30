window.onload = function() {
  if (window.location.host == "checkout.xola.app") {
  
    var submit_button = document.getElementsByClassName('action-submit')[0]
    if (submit_button) {
      submit_button.classList.add('disabled');


      function toggle_next_button() {
        var new_input = document.getElementById('accept_terms');
        var classlist = document.getElementsByClassName('action-submit')[0].classList
        if (new_input.checked) {
          classlist.remove("disabled")
        } else {
          classlist.add("disabled")
        }
      }
  

      var contact_info_container = document.getElementsByClassName('contact-info-container')[0]
      var new_row = document.createElement('div')
      new_row.classList.add('col-sm-12')
      new_row.classList.add('col-xs-12')
      var new_input = document.createElement('input')
      new_input.type = "checkbox"
      new_input.id = "accept_terms";
      new_input.onclick = toggle_next_button;
      var new_label = document.createElement('label');
      new_label.for = "checkbox";
      new_label.style = "padding:20px";
      new_label.textContent = "I'm good to go!"
      new_row.appendChild(new_input)
      new_row.appendChild(new_label)
      contact_info_container.appendChild(new_row)
    }
}
};
