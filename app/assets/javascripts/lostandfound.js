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