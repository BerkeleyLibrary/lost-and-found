
 function pagination_setup() {
  $( document ).ready(function() {
  document.getElementById('found_items_table').style.display = 'none';
    $('#found_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">',
        "iDisplayLength": 25
    } );


    $('#found_items_spinner').hide();
    document.getElementById('found_items_spinner').style.display = 'none';
    $('#found_items_table').show();
    document.getElementById('found_items_table').style.display = 'block';

    document.getElementById('claimed_items_table').style.display = 'none';
    $('#claimed_items_table').DataTable({
        "dom": '<"top"ip>rt<"bottom"><"clear">',
        "iDisplayLength": 25
    } );
    $('#claimed_items_spinner').hide();
    document.getElementById('claimed_items_spinner').style.display = 'none';
    $('#claimed_items_table').show();
    document.getElementById('claimed_items_table').style.display = 'block';
  });
  }

  function pagination_setup_claimed() {
    $( document ).ready(function() {
      document.getElementById('claimed_items_table').style.display = 'none';
      $('#claimed_items_table').DataTable({
          "dom": '<"top"ip>rt<"bottom"><"clear">',
          "iDisplayLength": 25
      } );
      $('#claimed_items_spinner').hide();
      document.getElementById('claimed_items_spinner').style.display = 'none';
      $('#claimed_items_table').show();
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

