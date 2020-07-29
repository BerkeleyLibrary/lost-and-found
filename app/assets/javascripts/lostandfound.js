
 function pagination_setup() {
    $('#found_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">'
    } );

    $('#found_items_spinner').hide();
    $('#found_items_table').show();

    $('#claimed_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">'
    } );
    $('#claimed_items_spinner').hide();
    $('#claimed_items_table').show();
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

