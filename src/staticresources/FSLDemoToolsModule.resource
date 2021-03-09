var app = angular.module('FSLDemoTools', []);

app.controller('FSLDemoToolsController', function($scope) {
	$scope.init=function(){
		$scope.tabClasses=["","","","",""];
		$scope.ChangeTab(0);
		$scope.working=false;
		$scope.confirmMoveNotification=false;
		$scope.turnOffMessages();
	//LocationMover vars
	$scope.locations=[];
  $scope.timezones=[];
	$scope.locationNameModel = "";
    $scope.locationNewLatitude = 0.000000;
    $scope.locationNewLongitude = 0.000000;
	$scope.selectedLat = "";
	$scope.selectedLong = "";
	$scope.createdSuccess = false;
	$scope.GetLocations();
	//$scope.MapInit();
	$scope.radius = 5;
	$scope.locationButtonStatus="Move Location";
  $scope.UserTz="";
  $scope.noGeolocation=true;
  //$scope.timezonePicklist="";


    Visualforce.remoting.Manager.invokeAction(
          RemoteActions.GetUserTz,
          function(tz, ev){
            if(ev.statusCode!=200){
              console.log("Error loading User Time zone:" +ev);
            }
            else{
              console.log("Loaded User Tz");
              $scope.UserTz= tz;
              $scope.$apply();
            }
          }, {escape: false});


	//ResotreData vars
		$scope.dateForDataRestore=$scope.getNextMonday();
		$scope.dataRestoreButtonStatus='Reset Demo Data';


	//TimeMover vars
	$scope.numofdaysModel=0;
	$scope.moveDatesButtonStatus='Move Dates';



  //Time zone Mover vars
    $scope.moveTZButtonStatus_NotWorking= "Move Hours and Update Timezone";
  $scope.moveTZButtonStatus_Working= "Processing...";

  $scope.moveTZButtonStatus= $scope.moveTZButtonStatus_NotWorking;
  $scope.selectedLocationTZmodel="";
  $scope.locationTZModel="";
  $scope.tzChanged=false;

}
$scope.ResizeMap = function(){
       google.maps.event.trigger(map, "resize");
}

//Start General
$scope.ChangeTab=function(tabIndex){
	if($scope.working){
		return;
	}
	$scope.showTab=tabIndex;
	for(var i=0; i<$scope.tabClasses.length; i++){
		if(i==tabIndex){
			$scope.tabClasses[i]="slds-active";
		}
		else{
			$scope.tabClasses[i]="";
		}
	}
}

$scope.confirmMove= function(){
	$scope.confirmMoveNotification=true;
	$scope.turnOffMessages();
}

$scope.startWorking=function(){
	$scope.working=true;
	$scope.confirmMoveNotification=false;
	if($scope.showTab==1){
      $scope.restoreData();
	}
	else if($scope.showTab==2){
    if($scope.locationNewLatitude=='' || $scope.locationNewLongitude==''){
         $scope.working=false;
      alert('Please Enter a valid address.');
      return;
    }
    else $scope.moveLocation();
	}
	else if($scope.showTab==3){
		  if($scope.numofdaysModel<-6 || $scope.numofdaysModel>6){
      $scope.moveDates();
    }
    else{
      $scope.working=false;
      alert('You can only move more than or less than 7 days.');
      return;
    }
	}
  else if($scope.showTab==4){
    $scope.moveTZ();
  }

}


$scope.finishMessage = function(msg, isSuccess){
	if(isSuccess){
		$scope.showSuccessNotification=true;
		$scope.successNotification=msg;
	}
	else{
		$scope.showErrorNotification=true;
		$scope.errorNotification=msg;
	}

}

$scope.turnOffMessages = function(){
	$scope.showSuccessNotification=false;
	$scope.showErrorNotification=false;
}
//End General


       //Start Location Mover
       $scope.MapInit= function(){
       	var map = new google.maps.Map(document.getElementById('map'), {
       		zoom: 12,
       		center: {lat:37.794185,lng:-122.395223},
       		mapTypeId: google.maps.MapTypeId.ROADMAP
       	});
       	$scope.mapInstance=map;
       	map.setOptions({ disableDoubleClickZoom: true });
       	var input = (document.getElementById('address-input'));
       	var searchBox = new google.maps.places.SearchBox(input);
       	map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

       	map.addListener('bounds_changed', function() {
       		searchBox.setBounds(map.getBounds());
       	});
       	searchBox.addListener('places_changed', function() {
       		var places = searchBox.getPlaces();

       		if (places.length == 0) {
       			return;
       		}
       		else{
       			var ll = new google.maps.LatLng(places[0].geometry.location.lat(), places[0].geometry.location.lng());
       			$scope.UpdateMap(ll);
       			$scope.UpdateAddress(ll);
       		} 
          //google.maps.event.trigger($scope.mapInstance, 'resize');

       	});

          //Adding event listener for double click on map
          map.addListener('dblclick', function(event){
            if($scope.noGeolocation) return;
          	ll = new google.maps.LatLng(event.latLng.lat(), event.latLng.lng(), true);
          	$scope.UpdateMap(ll);
          	$scope.UpdateAddress(ll);
          });
      }

      $scope.UpdateMap = function (latlng) {
      	$scope.selectedLat = latlng.lat();
      	$scope.selectedLong = latlng.lng();
      	if ($scope.marker == undefined) {
      		$scope.marker = new google.maps.Marker({
      			position: latlng,
      			map: $scope.mapInstance,
      			animation: google.maps.Animation.DROP,
      		});
      	}
      	else {
      		$scope.marker.setAnimation(google.maps.Animation.DROP);
      		$scope.marker.setPosition(latlng);
      	}

      	if ($scope.circle == undefined) {
      		$scope.circle = new google.maps.Circle({
      			center: latlng,
      			map: $scope.mapInstance,
      			radius: $scope.radius * 1000,
      			fillColor: '#23D452',
      			fillOpacity: 0.4,
      			strokeColor: '#20873C',
      			strokeOpacity: 0.7,
      			strokeWeight: 0.5
      		});
      	}
      	else
      	{
      		$scope.circle.setCenter(latlng);
      	}
      	$scope.mapInstance.setCenter(latlng);

        $scope.$apply();
      }

      $scope.UpdateAddress = function(latlng){
          //Updating the placeholder field with the address
          var geoCoder = new google.maps.Geocoder();
          geoCoder.geocode({ 'latLng': latlng }, function (response, y) {
          	if (y = "OK") {
          		if (response.length != 0) {
          			$scope.placehold = response[0].formatted_address;

                                               //Setting the New Location field with the city name
                                               $scope.locationNameModel = '';
                                               for (var i = 0; i < response[0].address_components.length; i++) {
                                               	if (response[0].address_components[i].types[0] == 'locality') {
                                               		$scope.locationNameModel = response[0].address_components[i].long_name;
                                               		break;
                                               	}
                                               }
                                               $scope.$apply();
                                           }
                                           else {
                                           	$scope.placehold = '';
                                           	$scope.locationNameModel = '';
                                           }
                                       }
                                   });
      }

      $scope.GetLocations = function () {
      	Visualforce.remoting.Manager.invokeAction(
      		RemoteActions.GetLocations,
      		function(lstLocations, ev){
      			if(ev.statusCode!=200){
      				console.log("Error loading locations:" +ev);
      			}
      			else{
      				console.log("Loaded Locations");
      				$scope.locations= lstLocations;
      				$scope.$apply();
              $scope.GetTimeZones();
      			}
      		}, {escape: false});
      }

      $scope.GetTimeZones = function () {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.GetTimeZones,
          function(lstTZs, ev){
            if(ev.statusCode!=200){
              console.log("Error loading timezones:" +ev);
            }
            else{
              console.log("Loaded Timezones");
              $scope.timezones= lstTZs;
              $scope.$apply();
              $scope.GetOperatingHours();
            }
          }, {escape: false});
      }

      $scope.GetOperatingHours = function () {
        Visualforce.remoting.Manager.invokeAction(
          RemoteActions.GetOperatingHours,
          function(lstOperatingHours, ev){
            if(ev.statusCode!=200){
              console.log("Error loading operating hours:" +ev);
            }
            else{
              console.log("Loaded Operating Hours");
              lstTemp=[];

              for(i=0; i<$scope.locations.length; i++){
                var operatingHoursId=$scope.locations[i].OperatingHoursId;
                var operatingHoursName;
                var operatingHoursTZ;

                for(j=0; j<lstOperatingHours.length; j++){
                  if(lstOperatingHours[j].Id==operatingHoursId){
                    operatingHoursName=lstOperatingHours[j].Name;
                    operatingHoursTZ=lstOperatingHours[j].TimeZone;
                  }
                }
                 lstTemp.push({Id:$scope.locations[i].Id, Name: $scope.locations[i].Name, Longitude:$scope.locations[i].Longitude, Latitude:$scope.locations[i].Latitude, OperatingHoursId:$scope.locations[i].OperatingHoursId, OperatingHoursName: operatingHoursName,OperatingHoursTZ: operatingHoursTZ });
              }

              $scope.locations= lstTemp;
              $scope.locationTZModel=$scope.timezones[0];
              $scope.selectedLocationTZmodel=$scope.locations[0];
              $scope.locationChangeTZ();
              $scope.$apply();
            }
          }, {escape: false});
      }

      $scope.moveLocation = function () {
      	$scope.locationButtonStatus="Processing...";

      	Visualforce.remoting.Manager.invokeAction(
      		RemoteActions.ChangeLocation, $scope.selectedLocation.Id, $scope.locationNameModel, $scope.locationNewLatitude, $scope.locationNewLongitude, 
      		function(msg, ev){
      			$scope.working=false;
      			$scope.locationButtonStatus="Move Location";
      			$scope.locationNameModel = "";
      			$scope.locations=[];
      			$scope.GetLocations();

      			if(ev.statusCode!=200){
      				console.log("Error moving locations");
      				console.log(ev);
      				  $scope.finishMessage('An error has occurred: '+ev.message+' Click here to continue.', false);
      			}
      			else{
      				console.log("Success");
      				console.log(msg);
      				$scope.finishMessage('Initiated the location mover. Please wait for email confirmation. Click here to continue.', true);
      			}
      			$scope.$apply();
      		});

      };

      $scope.locationChange = function () {
        google.maps.event.trigger(map, "resize");
      	if (!!$scope.selectedLocation) {
      		$scope.locationNameModel='';
          if($scope.selectedLocation.Latitude==undefined || $scope.selectedLocation.Longitude==undefined){
            $scope.noGeolocation=true;
            alert($scope.selectedLocation.Name + ' Does not have a Geolocation.');
            return;
          }
          $scope.noGeolocation=false;
      		var latlng = new google.maps.LatLng($scope.selectedLocation.Latitude, $scope.selectedLocation.Longitude);
      		if ($scope.marker == undefined) {
      			$scope.marker = new google.maps.Marker({
      				position: latlng,
      				map: $scope.mapInstance,
      				animation: google.maps.Animation.DROP,
      			});
      		}
      		else {
      			$scope.marker.setAnimation(google.maps.Animation.DROP);
      			$scope.marker.setPosition(latlng);
      		}

      		if ($scope.circle == undefined) {
      			$scope.circle = new google.maps.Circle({
      				center: latlng,
      				map: $scope.mapInstance,
      				radius: $scope.radius * 1000,
      				fillColor: '#23D452',
      				fillOpacity: 0.4,
      				strokeColor: '#20873C',
      				strokeOpacity: 0.7,
      				strokeWeight: 0.5
      			});
      		}
      		else {
      			$scope.circle.setCenter(latlng);
      		}
      		$scope.mapInstance.setCenter(latlng);
      	}
      };
     //End Location Mover

//Start Restore Data
$scope.getNextMonday = function(){

  var d = new Date();
  var day = d.getDay();

  if(day==0)
  	diff=d.getDate()+1;
  else
	diff = d.getDate() +8-day;

  return new Date(d.setDate(diff));
}

$scope.restoreData= function(){
	$scope.dataRestoreButtonStatus="Processing...";
		Visualforce.remoting.Manager.invokeAction(
      		RemoteActions.RestoreData, $scope.dateForDataRestore.getFullYear(),$scope.dateForDataRestore.getMonth()+1,$scope.dateForDataRestore.getDate(), 
      		function(msg, ev){
      			$scope.working=false;
      			$scope.dataRestoreButtonStatus="Restore Demo Data";
      			$scope.numofdaysModel = 0;

      			if(ev.statusCode!=200){
      				console.log("Error restoring data");
      				console.log(ev);
      				  $scope.finishMessage('An error has occurred: '+ev.message+' Click here to continue.', false);
      			}
      			else{
      				console.log("Success");
      				console.log(msg);
      				$scope.finishMessage('Succesfully initiated demo data reset. Please wait for email confirmation. Click here to continue.', true);
              $scope.GetLocations();
      			}
      			$scope.$apply();
      		});
}

//End Restore Data

//Start Move Date
$scope.moveDates=function(){
	$scope.timeButtonStatus="Processing...";
	   	Visualforce.remoting.Manager.invokeAction(
      		RemoteActions.MoveDates, $scope.numofdaysModel, 
      		function(msg, ev){
      			$scope.working=false;
      			$scope.timeButtonStatus="Move Dates";
      			$scope.numofdaysModel = 0;

      			if(ev.statusCode!=200){
      				console.log("Error moving time");
      				console.log(ev);
      				$scope.finishMessage('An error has occurred: '+ev.message+' Click here to continue.', false);
      			}
      			else{
      				console.log("Success");
      				console.log(msg);
      				$scope.finishMessage('Succesfully initiated date mover. Please wait for email confirmation. Click here to continue.', true);
      			}
      			$scope.$apply();
      		});
}
//End Move Date

//Start Move Hours

$scope.locationChangeTZ = function(){
  try{
  $scope.locationTZModel.value = $scope.selectedLocationTZmodel.OperatingHoursTZ;
    $scope.tzChanged=false;
  }
  catch(err){
    console.log('Error at locationChangeTZ():'+err);
  }
}

$scope.TimezoneChanged = function(){
  if($scope.locationTZModel.value==$scope.selectedLocationTZmodel.OperatingHoursTZ) $scope.tzChanged=false;
  else
    $scope.tzChanged=true;
}

$scope.moveTZ=function(){
  $scope.moveTZButtonStatus=$scope.moveTZButtonStatus_Working;
      Visualforce.remoting.Manager.invokeAction(
          RemoteActions.UpdateTimezones, $scope.selectedLocationTZmodel.Id, $scope.locationTZModel.value,
          function(msg, ev){
            $scope.working=false;
            $scope.moveTZButtonStatus=$scope.moveTZButtonStatus_NotWorking;
            $scope.tzChanged=false;
            $scope.GetLocations();

            if(ev.statusCode!=200){
              console.log("Error moving time zone");
              console.log(ev);
              $scope.finishMessage('An error has occurred: '+ev.message+' Click here to continue.', false);
            }
            else{
              console.log("Success");
              console.log(msg);
              $scope.finishMessage('Succesfully initiated time zone mover. Please wait for email confirmation. Click here to continue.', true);
            }
            $scope.$apply();
          });
}
//End Move Hours


 });
