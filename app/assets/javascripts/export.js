$(function(){
  var dpel = $('#datetimepicker')

  $('#runall').click(function(e) {
    var date = dpel.val()
    $.each($(".export"), function(k,v) {
      var url = 'export/' + code + '/' + date.format('YYYYMMDD')
      var code = $(v).closest('tr[data-code]').data('code')
      run(url,code,date)
    })
  })

  $('.export').click(function(e) {
    var date = moment(dpel.val(), "MM/DD/YYYY")
    var code = $(this).closest('tr[data-code]').data('code')
    console.log(code);
    var img = "<img src='/ajax-loader.gif'/>"
    $('.di-date#'+code).html(img)
    var url = 'export/' + code + '/' + date.format('YYYYMMDD')
    run(url,code,date)
  })

  var dp = dpel.datetimepicker({
    format: 'MM/DD/YYYY',
    defaultDate: new Date()
  });

  dp.on("change", function(e) {
    $.each($(".di-date"), function(k,v) {
      var date = moment(e.currentTarget.value, "MM/DD/YYYY")
      var code = $(this).closest('tr[data-code]').data('code')
      refresh(code,date)
    })
  })

  $('.refresh').click(function() {
    var code = $(this).closest('tr[data-code]').data('code')
    var date = moment(dpel.val(), "MM/DD/YYYY")
    console.log(date);
    refresh(code,date)
  })

  var run = function(url,code,date) {
    $.get(url, function(data, textStatus, jqXHR) {
      var id = data.job.id
      window.setTimeout(function() {
        $.get('/export/checkjob/' + id, function(data) {
          if (data.job == 'done') {
            $('.di-date#'+code).text("Finished")
          } else if (data.job.last_error) {
            $('.di-date#'+code).text(data.job.last_error)
          } else {
            $('.di-date#'+code).text("Running")
          }
          console.log(data)
        })
      }, 5000)
    })
  }

  var refresh = function(code,date) {
    var url = '/export/dyinfo/' + code + '/' + date.format('YYYYMMDD')
    $.get(url, function(data, textStatus, jqXHR) {
      if (data.info == null) {
        $('.di-date#'+code).text("None for " + date.format('MMMM D, YYYY'))
      } else {
        $('.di-date#'+code).text(data.info.ship_count)
      }
      // console.log(data.info);
    })
  }


})
