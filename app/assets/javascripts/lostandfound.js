
 function pagination_setup() {
  $(document).ready( function () {
    console.log( "ready!" );
    $('#found_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">'
    } );
    $('#claimed_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">'
    } );
    } );
  }
$(document).on("change", "#itemStatus", function(e){
    var select_val = $(this).val();
    if (select_val == 3) {
      $("#claimedBy").removeClass("hidden");
      $("#claimedByLabel").removeClass("hidden");
    } else {
      $("#claimedByLabel").addClass("hidden");
      $("#claimedBy").addClass("hidden");
      $("#claimedBy").val("");
    }
 });

 
 function toggleFunction() {
    document.getElementById("navbar-dropdown").classList.toggle("collapse");
  }

