
 function pagination_setup() {
  $( document ).ready(function() {
  document.getElementById('found_items_spinner').style.display = 'block';

    $('#found_items_table').DataTable({
      retrieve: true,
        "dom": '<"top"ip>rt<"bottom"><"clear">',
        "iDisplayLength": 25
    } );
    document.getElementById('found_items_spinner').style.display = 'none';
    document.getElementById('found_items_table_wrapper').style.display = 'block';

    $('#claimed_items_table').DataTable({
      retrieve: true,
        "dom": '<"top"ip>rt<"bottom"><"clear">',
        "iDisplayLength": 25
    } );
    document.getElementById('claimed_items_spinner').style.display = 'none';
    document.getElementById('claimed_items_table_wrapper').style.display = 'block';
  });
  }

  function pagination_setup_claimed() {
    $( document ).ready(function() {
      document.getElementById('claimed_items_spinner').style.display = 'block';
      document.getElementById('claimed_items_table').style.display = 'none';
      $('#claimed_items_table').DataTable({
           retrieve: true,
          "dom": '<"top"ip>rt<"bottom"><"clear">',
          "iDisplayLength": 25
      } );
      document.getElementById('claimed_items_spinner').style.display = 'none';
      document.getElementById('claimed_items_table').style.display = 'block';
    });
    }

$(document).on("change", "#itemStatus", function(e){
    var select_val = $(this).val();
    if (select_val == 3) {
      $("#claimedBy").removeClass("hidden");
      document.getElementById("claimedBy").setAttribute("required", true);
      $("#claimedByLabel").removeClass("hidden");
    } else {
      document.getElementById("claimedBy").removeAttribute("required");
      $("#claimedByLabel").addClass("hidden");
      $("#claimedBy").addClass("hidden");
      $("#claimedBy").val("");
    }
 });

 
 function toggleFunction() {
    document.getElementById("navbar-dropdown").classList.toggle("collapse");
  }

