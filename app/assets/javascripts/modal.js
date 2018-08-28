hideModal = function() {
  $("a.overlay").hide();
  $("#modal").animate({top: "100%"}, 500, function() {
    $("#modalContent iframe").remove();
    $("#modalTitle").text("");
    $("#modalOffice").text("");
    $("#modalContent").html("");
  });
  return true;
}