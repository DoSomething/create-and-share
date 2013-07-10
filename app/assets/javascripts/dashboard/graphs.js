$(document).ready(function(){

  $(".update").each(function() {
    var scope = $(this)
    scope.find("input[type='submit']").click(function(e) {
      e.preventDefault();
      var error = [];
      if(scope.find("input[type='date']").val() == "") {
        error.push("Please enter a date.");
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1;
        var yyyy = today.getFullYear();
        if(dd < 10)
          dd='0'+dd
        if(mm < 10)
          mm='0'+mm
        today = yyyy+'-'+mm+'-'+dd;
        scope.find("input[type='date']").val(today);
      }
      if(scope.find("input[type='number']").val() % 1 != 0 || scope.find("input[type='number']").val() < 1) {
        error.push("Unacceptable number. Please enter a positive integer.");
        scope.find("input[type='number']").val("5")
      }
      if(error.length > 0) {
        alert(error.join("\n\n"));
      }
      else {
        $.ajax({
          type: "GET",
          data: scope.find("form").serialize(),
          dataType: "json",
          url: "/dashboard",
          success: function(data) {
            var title = data["title"];
            var target = "";
            var ticks = [], labels = [], points = [];

            if(title == "User Stats") {
              target = "usersLine";
              var total = [], totalPoints = [], postsPer = [], sharesPer = [];
              $.each(data["nUsers"], function(tick, point) {
                totalPoints.push(point);
                ticks.push(tick);
              });
              $.each(data["totalUsers"], function(tick, point) {
                total.push(point);
                if(point == 0) {
                  postsPer.push(0);
                  sharesPer.push(0);
                }
                else {
                  postsPer.push(data["totalPosts"][tick] / point);
                  sharesPer.push(data["totalShares"][tick] / point);
                }
              });
              points = [total, totalPoints, postsPer, sharesPer];
              labels = [
                {label: "Total Users"},
                {label: "New Users"},
                {label: "Posts per User"},
                {label: "Shares per User"}
              ]
            }
            else if(title == "Pet Stats") {
              target = "petsLine";
              var total = [], totalAdopted = [], newlyAdopted = [], totalPoints = [], catPoints = [], dogPoints = [], otherPoints = [];
              $.each(data["totalPosts"], function(tick, point) {
                total.push(point);
              });
              $.each(data["totalAdopted"], function(tick, point) {
                totalAdopted.push(point);
              });
              $.each(data["nAdopted"], function(tick, point) {
                newlyAdopted.push(point);
              });
              $.each(data["nPosts"], function(tick, point) {
                totalPoints.push(point);
                ticks.push(tick);
              });
              $.each(data["nCats"], function(tick, point) {
                catPoints.push(point);
              });
              $.each(data["nDogs"], function(tick, point) {
                dogPoints.push(point);
              });
              $.each(data["nOthers"], function(tick, point) {
                otherPoints.push(point);
              });
              points = [total, totalAdopted, newlyAdopted, totalPoints, catPoints, dogPoints, otherPoints];
              labels = [
                {label: "Total Posts"},
                {label: "Total Adopted Pets"},
                {label: "Newly Adopted Pets"},
                {label: "New Posts"},
                {label: "New Cat Posts"},
                {label: "New Dog Posts"},
                {label: "New Other Posts"}
              ]
            }
            else if(title == "Share Stats") {
              target = "sharesLine";
              var total = [], totalPoints = [], catPoints = [], dogPoints = [], otherPoints = [], perPost = [];
              $.each(data["nShares"], function(tick, point) {
                totalPoints.push(point);
                ticks.push(tick);
              });
              $.each(data["nCatShares"], function(tick, point) {
                catPoints.push(point);
              });
              $.each(data["nDogShares"], function(tick, point) {
                dogPoints.push(point);
              });
              $.each(data["nOtherShares"], function(tick, point) {
                otherPoints.push(point);
              });
              $.each(data["totalShares"], function(tick, point) {
                total.push(point);
                var totalPosts = data["totalPosts"][tick];
                if(totalPosts == 0)
                  perPost.push(0);
                else
                  perPost.push(point / data["totalPosts"][tick]);
              });
              console.log(perPost);
              points = [total, totalPoints, catPoints, dogPoints, otherPoints, perPost];
              labels = [
                {label: "Total Shares"},
                {label: "New Shares"},
                {label: "New Cat Shares"},
                {label: "New Dog Shares"},
                {label: "New Other Shares"},
                {label: "Shares per Post"}
              ]
            }

            $("#" + target).empty();
            $.jqplot(target, points, {
              title: title,
              series: labels,
              axes: {
                xaxis: {
                  ticks: ticks,
                  renderer: $.jqplot.CategoryAxisRenderer
                }
              },
              axesDefaults: {
                tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                tickOptions: {
                  angle: -30,
                  fontSize: '10pt'
                }
              },
              legend: {
                show: true,
                placement: 'outsideGrid',
                location: 's'
              },
              highlighter: {
                show: true,
                sizeAdjust: 7.5,
                tooltipContentEditor: function (str, seriesIndex, pointIndex, plot) {
                  return str.substring(str.indexOf(",") + 2);
                },
                bringSeriesToFront: true
              }
            });
          }
        });
      }
    });
  });

  $("input[type='submit']").click();

  var nPets = $("#petsBar").data("total");
  var nUsers = $("#usersBar").data("total");
  var nShares = $("#sharesBar").data("total");

  //pets pie
  var petsPieData = [
    ['Cats', $("#petsPie").data("cats")],['Dogs', $("#petsPie").data("dogs")], ['Other', $("#petsPie").data("others")]
  ];
  var petsPie = jQuery.jqplot ('petsPie', [petsPieData], 
    { 
      title: "Pet Type Percentage",
      seriesDefaults: {
        // Make this a pie chart.
        renderer: jQuery.jqplot.PieRenderer, 
        rendererOptions: {
          // Put data labels on the pie slices.
          // By default, labels show the percentage of the slice.
          showDataLabels: true
        }
      }, 
      legend: { show:true, location: 'e' }
    }
  );

  //shares pie
  var sharesPieData = [
    ['Cats', $("#sharesPie").data("cat")],['Dogs', $("#sharesPie").data("dog")], ['Other', $("#sharesPie").data("other")]
  ];
  var petsPie = jQuery.jqplot ('sharesPie', [sharesPieData], 
    { 
      title: "Share Type Percentage",
      seriesDefaults: {
        // Make this a pie chart.
        renderer: jQuery.jqplot.PieRenderer, 
        rendererOptions: {
          // Put data labels on the pie slices.
          // By default, labels show the percentage of the slice.
          showDataLabels: true
        }
      }, 
      legend: { show:true, location: 'e' }
    }
  );

  //pets bar
  var total = [$("#petsBar").data("total")];
  var cats = [$("#petsBar").data("cats")];
  var dogs = [$("#petsBar").data("dogs")];
  var others = [$("#petsBar").data("others")];
  // Can specify a custom tick Array.
  // Ticks should match up one for each y value (category) in the series.
  var ticks = ['All time'];
  var petsBar = $.jqplot('petsBar', [total, cats, dogs, others], {
      title: "Pets Stats",
      // The "seriesDefaults" option is an options object that will
      // be applied to all series in the chart.
      seriesDefaults:{
          renderer:$.jqplot.BarRenderer,
          rendererOptions: {fillToZero: true},
          pointLabels: { show: true, location: 'n', edgeTolerance: -15 },
      },
      // Custom labels for the series are specified with the "label"
      // option on the series option.  Here a series option object
      // is specified for each series.
      series:[
          {label:'Total Pets'},
          {label:'Cats'},
          {label:'Dogs'},
          {label:'Others'}
      ],
      // Show the legend and put it outside the grid, but inside the
      // plot container, shrinking the grid to accomodate the legend.
      // A value of "outside" would not shrink the grid and allow
      // the legend to overflow the container.
      legend: {
          show: true,
          placement: 'outsideGrid'
      },
      axes: {
          // Use a category axis on the x axis and use our custom ticks.
          xaxis: {
              renderer: $.jqplot.CategoryAxisRenderer,
              ticks: ticks
          },
          // Pad the y axis just a little so bars can get close to, but
          // not touch, the grid boundaries.  1.2 is the default padding.
      }
  });

  //users bar
  var total = [$("#usersBar").data("total")];
  var mean = [ nPets / nUsers ];
  var shares = [ nShares / nUsers ]
  // Can specify a custom tick Array.
  // Ticks should match up one for each y value (category) in the series.
  var ticks = ['All time'];
  var usersBar = $.jqplot('usersBar', [total, mean, shares], {
      title: "User Stats",
      // The "seriesDefaults" option is an options object that will
      // be applied to all series in the chart.
      seriesDefaults:{
          renderer:$.jqplot.BarRenderer,
          rendererOptions: {fillToZero: true},
          pointLabels: { show: true, location: 'n', edgeTolerance: -15 },
      },
      // Custom labels for the series are specified with the "label"
      // option on the series option.  Here a series option object
      // is specified for each series.
      series:[
          {label:'Total Users'},
          {label:'Posts per user'},
          {label: 'Shares per user'}
      ],
      // Show the legend and put it outside the grid, but inside the
      // plot container, shrinking the grid to accomodate the legend.
      // A value of "outside" would not shrink the grid and allow
      // the legend to overflow the container.
      legend: {
          show: true,
          placement: 'outsideGrid'
      },
      axes: {
          // Use a category axis on the x axis and use our custom ticks.
          xaxis: {
              renderer: $.jqplot.CategoryAxisRenderer,
              ticks: ticks
          },
          // Pad the y axis just a little so bars can get close to, but
          // not touch, the grid boundaries.  1.2 is the default padding.
      }
  });

  //shares bar
  var total = [$("#sharesBar").data("total")];
  var cat = [$("#sharesBar").data("cat")];
  var dog = [$("#sharesBar").data("dog")];
  var other = [$("#sharesBar").data("other")];
  var mean = [ nShares / nPets ];
  // Can specify a custom tick Array.
  // Ticks should match up one for each y value (category) in the series.
  var ticks = ['All time'];
  var sharesBar = $.jqplot('sharesBar', [total, cat, dog, other, mean], {
      title: "Share Stats",
      // The "seriesDefaults" option is an options object that will
      // be applied to all series in the chart.
      seriesDefaults:{
          renderer:$.jqplot.BarRenderer,
          rendererOptions: {fillToZero: true},
          pointLabels: { show: true, location: 'n', edgeTolerance: -15 },
      },
      // Custom labels for the series are specified with the "label"
      // option on the series option.  Here a series option object
      // is specified for each series.
      series:[
          {label:'Total Shares'},
          {label:'Cat Shares'},
          {label:'Dog Shares'},
          {label:'Other Shares'},
          {label:'Shares per Post'}
      ],
      // Show the legend and put it outside the grid, but inside the
      // plot container, shrinking the grid to accomodate the legend.
      // A value of "outside" would not shrink the grid and allow
      // the legend to overflow the container.
      legend: {
          show: true,
          placement: 'outsideGrid'
      },
      axes: {
          // Use a category axis on the x axis and use our custom ticks.
          xaxis: {
              renderer: $.jqplot.CategoryAxisRenderer,
              ticks: ticks
          },
          // Pad the y axis just a little so bars can get close to, but
          // not touch, the grid boundaries.  1.2 is the default padding.
      }
  });

});