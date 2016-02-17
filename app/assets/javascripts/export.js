$(function(){
  $('.export').click(function(e) {
    url = 'export/' + $(this).data('code')
    $.get(url, function(data, textStatus, jqXHR) {
      console.log(data);
    })
  })

  
})
