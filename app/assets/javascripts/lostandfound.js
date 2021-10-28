

$(document).on("change", "#status", function(e){
    var select_val = $(this).val();
    if (select_val == 3) {
      $("#claimed_by").removeClass("hidden");
      document.getElementById("claimed_by").setAttribute("required", true);
      $("#claimed_byLabel").removeClass("hidden");
    } else {
      document.getElementById("claimed_by").removeAttribute("required");
      $("#claimed_byLabel").addClass("hidden");
      $("#claimed_by").addClass("hidden");
      $("#claimed_by").val("");
    }
 });

 
 function toggleFunction() {
    document.getElementById("navbar-dropdown").classList.toggle("collapse");
  }
