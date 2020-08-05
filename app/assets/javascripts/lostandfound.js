
 function pagination_setup() {
  $( document ).ready(function() {
    $('#found_items_spinner').css('display', 'block');
    $('#found_items_table').css('display', 'none');
     $('#found_items_table').DataTable({
          retrieve: true,
         "dom": '<"top"ip>rt<"bottom"><"clear">',
         "iDisplayLength": 25
     } );
    $('#found_items_spinner').css('display', 'none');
     $('#found_items_table').css('display', 'block');

    $('#claimed_items_spinner').css('display', 'block');
    $('#claimed_items_table').css('display', 'none');
     $('#claimed_items_table').DataTable({
          retrieve: true,
         "dom": '<"top"ip>rt<"bottom"><"clear">',
         "iDisplayLength": 25
     } );
    $('#claimed_items_spinner').css('display', 'none');
     $('#claimed_items_table').css('display', 'block');
  });
  }

  function pagination_setup_claimed() {
    $( document ).ready(function() {
     $('#claimed_items_spinner').css('display', 'block');
     $('#claimed_items_table').css('display', 'none');
      $('#claimed_items_table').DataTable({
           retrieve: true,
          "dom": '<"top"ip>rt<"bottom"><"clear">',
          "iDisplayLength": 25
      } );
     $('#claimed_items_spinner').css('display', 'none');
      $('#claimed_items_table').css('display', 'block');
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

