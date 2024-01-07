import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output", "searchForm", "addForm", "copySource"]
  connect() {
    // this.fetch_residence()
    
  }

  fetch_residence() {
    var url = window.location.href + "/users"
    fetch(url, { headers: { accept: "text/html" } })
    .then(response => response.text())
    .then((html) => {
      this.outputTarget.innerHTML = html
    })
  }

  search() {
    this.searchFormTarget.requestSubmit()
  }

  add_new_residence() {
    this.addFormTarget.requestSubmit()
  }

  copy() {
    
    let uuid = document.getElementById("subdivision_uuid")
    console.log(uuid)
    // this.copySourceTarget.value = window.location.href + "/subdivision_setting/" + uuid + "/prepaire_register_link"
    navigator.clipboard.writeText(this.copySourceTarget.value)
  }
}
