hideModal = function() {
  $("#modal").animate({top: "100%"}, 500, function() {
    $("#modalContent iframe").remove();
    $("#modalTitle").text("");
    $("#modalOffice").text("");
    $("#modalContent").html("");
    $("a.overlay").hide();
  });
  return true;
}