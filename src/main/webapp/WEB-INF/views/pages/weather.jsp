<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="stylesheet" 	href="static/css/jquery-ui.min.css">
<script src="static/js/jquery-1.12.4.min.js"></script>
<script src="static/js/jquery-ui.min.js"></script>

<script src="static/js/highcharts.js"></script>
<script src="static/js/exporting.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<script>
var tempCityArray = new Array();
var cityUrlCombination = new Array();

$(document).ready(function(){
    $("#wu_temperature_chart").hide();
    $("#wu_wind_chart").hide();
});

/* Write JavaScript here */
$(document).ready(function ($) {
	
    $('#wu_weather_search_city_zip').keyup(function () {
    
    	tempCityArray = new Array();
    	cityUrlCombination = new Array();
    	var tempCityName;
    	
    	var value = $(this).val();
        $.ajax({
        	url: "http://autocomplete.wunderground.com/aq?&cb=call=?",		
        	dataType: "jsonp",
            data: {
                "query": value
            },
            crossDomain: true,
            success: function (parsed_json) {            	
            	var ccc = $.each(parsed_json.RESULTS, function (i, item) {
                    tempCityName =(parsed_json.RESULTS[i].name);
                    tempCityArray.push(tempCityName);
                    cityUrlCombination[tempCityName] = parsed_json.RESULTS[i].l;                     
                });
            	$("#wu_weather_search_city_zip").autocomplete({
                    source: tempCityArray
                });
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert(xhr.status);
                alert(thrownError);
            }
        });
    });
});

$(document).ready(function ($) {
    	
	$("#wu_weather_search_form").submit(function(event) {
		event.preventDefault();
    	var i;
        var out;
        var temp;
        var feel;
        var wSpeed;
    	var hours = [];
    	var windSpeed = [];
    	var temperature = new Array();
    	var feelsLike = new Array();
    	var value = $("#wu_weather_search_city_zip").val();
    	var locationURL = cityUrlCombination[value];
    	
    	console.log(locationURL); //Dallas - /q/zmw:75201.1.99999
    	var a = "http://api.wunderground.com/api/6bbe255086682579/hourly"+locationURL+".json";
        $.ajax({
        	url: "http://api.wunderground.com/api/6bbe255086682579/hourly"+locationURL+".json",
            //url: "http://api.wunderground.com/api/6bbe255086682579/geolookup/q/autoip.json",
            //url:"http://autocomplete.wunderground.com/aq?&c=US&cb=call=?",		
            dataType: "jsonp",
            crossDomain: true,
            success: function (parsed_json) {
            	console.log(parsed_json);
            	var ccc = $.each(parsed_json.hourly_forecast, function (i, item) {
                    feel = (parsed_json.hourly_forecast[i].feelslike.english);
                    feelsLike.push(feel);
                    if(feelsLike.length == 24){
                    	return false;
                    }
                });
            	var cc = $.each(parsed_json.hourly_forecast, function (i, item) {
                    temp = (parsed_json.hourly_forecast[i].temp.english);
                    temperature.push(temp);
                    if(temperature.length == 24){
                    	return false;
                    }
                });
            	
            	var c = $.each(parsed_json.hourly_forecast, function (i, item) {
                    out = (parsed_json.hourly_forecast[i].FCTTIME.hour);
                    hours.push(out);
                    if(hours.length ==24){
                    	return false;
                    }
                });
            	
            	var c = $.each(parsed_json.hourly_forecast, function (i, item) {
                    wSpeed = (parsed_json.hourly_forecast[i].wspd.english);
                    windSpeed.push(wSpeed);
                    if(windSpeed.length ==24){
                    	return false;
                    }
                });
            	
            	for (var i = 0; i < temperature.length; i++) {
            		temperature[i] = parseInt(temperature[i]);
            	}
            	for (var i = 0; i < feelsLike.length; i++) {
            		feelsLike[i] = parseInt(feelsLike[i]);
            	}
            	for (var i = 0; i < windSpeed.length; i++) {
            		windSpeed[i] = parseInt(windSpeed[i]);
            	}
            	
            	$("#wu_temperature_chart").show();
            	drawTemperatureChart(hours, temperature, feelsLike);
            	$("#wu_wind_chart").show();
            	drawWindSpeedChart(hours, windSpeed);
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert(xhr.status);
                alert(thrownError);
            }
        });
    });
});

function drawTemperatureChart(hours, temperature, feelsLike) {	
$(function () {
    Highcharts.chart('wu_temperature_chart', {
        title: {
            text: 'Next 24 hour Temperature',
        },
        subtitle: {
            text: 'Source: www.wunderground.com',
        },
        xAxis: {
        	title: {
                text: 'speed (mph)'
            },
            categories: hours
        },
        yAxis: {
            title: {
                text: 'Temperature (°F)'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        plotOptions: {
            line: {
                dataLabels: {
                    enabled: true
                },
                enableMouseTracking: true
            }
        },
        tooltip: {
            valueSuffix: '°F'
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: [{
            name: 'Actual Temperature',
            data: temperature
        }, {
            name: 'Feels Like',
            data: feelsLike
        }]
    });
});
}

function drawWindSpeedChart(hours, windSpeed) {
$(function () {
    var chart = Highcharts.chart('wu_wind_chart', {

        title: {
            text: 'Next 24 hour Wind Speed'
        },

        subtitle: {
            text: 'Source: www.wunderground.com'
        },

        xAxis: {
        	title: {
                text: 'hours'
            },
            categories: hours
        },
        yAxis: {
            title: {
                text: 'speed (mph)'
            },
        },

        series: [{
            type: 'column',
            colorByPoint: true,
            data: windSpeed,
            showInLegend: false
        }]

    });
});
}

</script>

</head>
<body>
<div class="container">
	<div class="panel panel-success">
		<div class="panel-heading"><b style="color: green">Jquery - Ajax Features</b></div>
		<div class="panel-body">	
	
		<div class="container-fluid text-center">
			<label class="control-label">Find Weather Details for next 24 hours by city name/zip code</label>
			<form class="form-inline" id="wu_weather_search_form">
				<input type="text" class="form-control" size="30" id="wu_weather_search_city_zip" placeholder="City name or Zip code">
				<button class="btn btn-success" id="wu_weather_search_button">Get weather</button>
				<br>
			</form>
			<div id="wu_temperature_chart" style="min-width: 200px; height: 250px; margin: 0 auto"></div>
			<div id="wu_wind_chart" style="min-width: 200px; height: 250px; margin: 0 auto"></div>
		</div>

		</div>
		<div class="panel-footer">
			<b style="color: green">https://www.wunderground.com</b>
		</div>
	</div>
</div>

</body>
</html>