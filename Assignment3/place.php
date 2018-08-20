<!DOCTYPE html>
<?php 
    error_reporting(-1);
    $lat = 0;
    $lon = 0;
    $keyword = "";
    $distance = "";
    $location = "";
    $category = "default";
    $place_api_json_res = NULL;
    $place_detail_api_json_res = NULL;

    if(isset($_POST['submit']))
    {
        if (isset($_POST['keyword']) && isset($_POST['here'])) {
            
            $keyword = $_POST['keyword'];
            $category = $_POST['category'];
            $distance = (!empty($_POST['radius']) ? ($_POST['radius']) : 10);
            
            if (empty($_POST['location'])) {

                $lat_lon_info = $_POST['hidden-location'];
                $lat_lon_object = json_decode($lat_lon_info, true);

                $lat = $lat_lon_object['lat'];
                $lon = $lat_lon_object['lon'];
                
            } else {

                $location = $_POST['location'];

                $url = "https://maps.googleapis.com/maps/api/geocode/json?address=" . urlencode($location) . "&key=AIzaSyBzyGygrjfuyoK_UAY2rdvHyCwEVz080lc";
                
                $response = file_get_contents($url);
                $json_res = json_decode($response, true);
                
                if (!empty($json_res['results'])) {

                    $result = $json_res['results'][0];
                    $lat = $result['geometry']['location']['lat'];
                    $lon = $result['geometry']['location']['lng'];
                
                } else {
                    $location_error = true;
                }
            }

            if ($lat && $lon) {
                $url = NULL;

                // append lat & long.
                $url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" . $lat . "," . $lon;

                // append radius.
                $url = $url . "&radius=" . $distance * 1609;

                // append type.
                $url = $url . "&type=" . urlencode($_POST['category']);

                // append keyword.
                $url = $url . "&keyword=" . urlencode($_POST['keyword']); 

                // append key.
                $url = $url . "&key=AIzaSyAhe6BLSXH7IWbzzA4uaVssQu05lUBw8sk";

                $place_api_json_res = json_encode(file_get_contents($url));
            
            } 
        }
    }

    if (isset($_GET['place_id']) && !isset($_POST['submit'])) 
    {
        $place_id = $_GET['place_id'];
        $distance = $_GET['distance'];
        $keyword  = $_GET['keyword'];
        $category = $_GET['category'];
        $location = $_GET['location'];
        
        $url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=". urlencode($place_id) . "&key=AIzaSyAjs2WCrzLgGwKE8Epj6Pb0xVlzkkrbeTQ";
        
        $json_res = file_get_contents($url);
        $place_detail_api_json_res = json_encode($json_res);
        $json_res = json_decode($json_res, true);
     
        if (!empty($json_res['result'])) {
            
            // code for saving photos on server.
            $photos = array();
            $photos = isset($json_res['result']['photos']) ? $json_res['result']['photos'] : array();
            $iter = count($photos) < 5 ? count($photos) : 5;
            
            for ($x = 0; $x < $iter; $x++) {

                $max_width = $photos[$x]['width'];
                $photo_reference = $photos[$x]['photo_reference'];
                
                $url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=" . $max_width . "&photoreference=" . $photo_reference . "&key=AIzaSyCBySLe96XKPFJr3NhJrpwaSMp_2inmaL4";
                
                $response = file_get_contents($url);
                
                $filename = "image" . $x . ".jpg";
                $response = $response;
                
                file_put_contents($filename, $response);
            }
        }
    }
?>

<html>
    <head>
        <style>
            #map {
                width: 430px;
                height: 400px;
                background-color: grey;
              }
            
            #option {
                width: 110px;
                height: 150px;
                line-height: 50px;
                background-color: #F0F0F0; 
            }
            
            #form {
                padding-left: 450px;
                padding-right: 450px;
            }
            
            #manual-location {
                padding-left:324px; 
                line-height: 30px;
            }
            
            #form-buttons {
                padding-left:80px;
                line-height: 45px;
            }
            
            #places-list {
               padding-top: 25px; 
            }
            
            #place-table-row {
                text-decoration: none; 
                color:black; 
                margin-left: 20px;
            }
            
            #photos-reviews {
                line-height: 20px;
                margin-top: -10px;
                text-align: center; 
            }
            
            #reviews {
                padding-left: 450px;
                padding-right: 450px;
            }
            
            #photos {
                padding-left: 460px;
                padding-right: 440px;
            }
            
            #option a {
                display: block;
                padding-left: 8px;
            }
            
            #option a:hover {
                background-color: #ccc;
            }
            
        </style>
        
        <script>
  
            function resetForm() {
                document.getElementById("submit-form").reset();
                document.getElementById("places-list").innerHTML = "";
                document.getElementById("location-textbox").disabled = true;
            }
            
            function checkRadioButtom() {
                if (document.getElementById("here").checked) {
                    document.getElementById("location-textbox").disabled = true;
                } else {
                    document.getElementById("location-textbox").disabled = false;
                }
            }
            
            function showReviews() {
                var review_div = document.getElementById("reviews");
                var review_arrow = document.getElementById("review-arrow")
                if (review_div.style.display !== 'none') {
                    document.getElementById("changeReviewHeading").innerHTML = "click to show reviews";
                    review_div.style.display = 'none';
                    review_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png";
                }
                else {
                    document.getElementById("changeReviewHeading").innerHTML = "click to hide reviews";
                    review_div.style.display = 'block';
                    review_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_up.png";
                }
                
                var photos_div = document.getElementById("photos");
                var photo_arrow = document.getElementById("photo-arrow") 
                if (photos_div.style.display === 'block') {
                    photos_div.style.display = 'none';
                    document.getElementById("changePhotoHeading").innerHTML = "click to show photos";
                    photo_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png";
                }
            }
            
            function showPhotos() {
                var photo_div = document.getElementById("photos");
                var photo_arrow = document.getElementById("photo-arrow")
                if (photo_div.style.display !== 'none') {
                    document.getElementById("changePhotoHeading").innerHTML = "click to show photos";
                    photo_div.style.display = 'none';
                    photo_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png";
                }
                else {
                    document.getElementById("changePhotoHeading").innerHTML = "click to hide photos";
                    photo_div.style.display = 'block';
                    photo_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_up.png"
                }
                
                var review_div = document.getElementById("reviews");
                var review_arrow = document.getElementById("review-arrow")
                if (review_div.style.display === 'block') {
                    review_div.style.display = 'none';
                    document.getElementById("changeReviewHeading").innerHTML = "click to show reviews";
                    review_arrow.src = "http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png";
                }
            }
        </script>
        
    </head>
    
    <body>
        <div id="form">
            <form id="submit-form" style="background-color:#FAFAFA" action="" method="POST">
                <fieldset style="font-weight:600; line-height: 26px">
                    <h1 style="text-align: center; font-style: italic; margin-top: 0px; margin-bottom: 15px; font-weight: 600;"> Travel and Entertainment Search</h1><hr>
                    Keyword <input type="text" id="keyword" name="keyword" required><br>
                    Category <select id="category" name="category">
                                <option value="default">Default</option>
                                <option value="cafe">Cafe</option>
                                <option value="bakery">Bakery</option>
                                <option value="restaurant">Restaurant</option>
                                <option value="beauty_salon">Beauty Salon</option>
                                <option value="casino">Casino</option>
                                <option value="movie_theater">Movie Theater</option>
                                <option value="lodging">Lodging</option>
                                <option value="airport">Airport</option>
                                <option value="train_station">Train Station</option>
                                <option value="bus_station">Bus Station</option>
                             </select><br>
                    Distance (miles) <input type="text" id="distance" name="radius" placeholder="10"> 
                    from 
                    <input type="radio" id="here" name="here" value="here" onclick="checkRadioButtom()" checked="checked">     
                    <label style="font-weight:500">Here</label>
                    <input type="hidden" id="hidden-location" name="hidden-location" value="hidden-location">

                    <div id="manual-location">
                        <input type="radio" id="location" name="here" value="location" onclick="checkRadioButtom()">
                        <input type="text" id="location-textbox" name="location" placeholder="location" required disabled><br>
                    </div>

                    <div id=form-buttons>
                        <input type="submit" id="search-button" name="submit" value="Search" disabled>
                        <input type="button" id="clear-button" name="clear" onclick="resetForm()" value="Clear">
                    </div> 
                </fieldset>
            </form>
        </div>
        <div id="places-list"></div>
        <div id="map" style="display:none; position:absolute; z-index:80";></div>
        <div id="option" style="display:none; position:absolute; z-index:80">
            <a id="walk" onclick="calculateDistance('walk')">Walk There</a>
            <a id="bike" onclick="calculateDistance('bike')">Bike There</a>
            <a id="drive" onclick="calculateDistance('drive')">Drive There</a>
        </div>
    </body>
</html>


<script>
    var place_api_json_string;
    window.onload = function () {
        
        var keyword = '<?php echo $keyword; ?>';
        var distance = '<?php echo $distance; ?>';
        var category = '<?php echo $category; ?>';
        var location = '<?php echo $location; ?>';
        
        document.getElementById("keyword").value = keyword;
        document.getElementById("category").value = category;
        document.getElementById("distance").value = distance;
     
        if (location !== '') {
            document.getElementById("location").checked = true;
            document.getElementById("location-textbox").value = location;
            document.getElementById("location-textbox").disabled = false;
        } else {
            document.getElementById("here").checked = true;
        }
        
        var method = "GET";
        var url = "http://ip-api.com/json/";

        var xhr = new XMLHttpRequest();
        xhr.open(method, url, true);
        xhr.onreadystatechange = function () {
            if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var location_details = JSON.parse(xhr.responseText);
                var lat_lon_object = {
                    "lat": location_details["lat"],
                    "lon": location_details["lon"]
                };

                document.getElementById("search-button").disabled = false;
                document.getElementById("hidden-location").setAttribute("value", JSON.stringify(lat_lon_object));
            }
        };
        xhr.send();
        
        // code for places api
        location_error = <?php echo (!empty($location_error) ? $location_error : '""'); ?>;
        place_api_json_string = <?php echo (!empty($place_api_json_res) ? $place_api_json_res : '""'); ?>;
        
        if ( place_api_json_string != "" ) {
            html_text = "";
            jsonDoc = JSON.parse(place_api_json_string);
            
            if ( jsonDoc.results.length == 0 ) {

                html_text = html_text + "<div style='text-align:center'>No records have been found</div>";

            } else {
               
                // constructing table (Header) 
                html_text += "<HTML><HEAD></HEAD><BODY><CENTER>";
                html_text += "<TABLE BORDER='2' style='border-collapse: collapse'><tr>"; 

                var headers = ["Category", "Name", "Address"];
                for (i=0; i < headers.length; i++) {
                    if (headers[i] == "Category") {   
                        html_text += "<th style='width: 110px;'>" + headers[i] + "</th>"
                    } else {
                        html_text += "<th>" + headers[i] + "</th>"
                    }
                }
                html_text += "</tr>";

                // constructing table (Body)
                count = 0;
                var places_object = jsonDoc.results;
                for (i=0; i< places_object.length; i++) 
                {
                    html_text += '<tr>';
                    html_text += '<td><img style="width:60px;height:40px;" src="' + places_object[i].icon  + '"></td>';
                    html_text += '<td><a id="place-table-row" href="place.php?place_id=' +  places_object[i].place_id + '&&keyword=' + keyword + '&&category=' + category + '&&distance=' + distance + '&&location=' + location + '">' + places_object[i].name  + '</td>';
                    html_text += '<td id="mapid' + count + '"><a id="place-table-row" href="#" onclick="showMap(' + places_object[i].geometry.location.lat + ',' +  places_object[i].geometry.location.lng + ', \'mapid' + count + '\')">' + places_object[i].vicinity + '</td>';
                    html_text += '</tr>';
                    count =  count + 1;
                }
                html_text += '</tbody></table>';
            }
            
            var places_list = document.getElementById("places-list");
            places_list.innerHTML = html_text;
        
        } else if ( location_error ){
            html_text = "<div style='text-align:center'>No records have been found, please enter the valid Location.</div>";
            var places_list = document.getElementById("places-list");
            places_list.innerHTML = html_text;
        }
        
        // code for place detail api
        $place_detail_api_json_string = <?php echo (!empty($place_detail_api_json_res) ? $place_detail_api_json_res : '""'); ?>;
        
        if ( $place_detail_api_json_string != "" ) 
        {
            html_text = "<div id='photos-reviews'>";
            jsonDoc = JSON.parse($place_detail_api_json_string);
            
            if ( jsonDoc.result.length != 0 ) {
                
                var searched_item_name = jsonDoc.result.name;
                html_text += "<h3>" + searched_item_name + "</h3><br>";
                
                // code for showing reviews
                html_text += "<p id='changeReviewHeading'> click to show reviews </p>";
                html_text += "<a onclick='showReviews()'><img id='review-arrow' style='width:30px;height:20px;' src='http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png'></img></a>";
                html_text += "<div id='reviews' style='display:none'>";
                
                var reviews = 'reviews' in jsonDoc.result? jsonDoc.result.reviews : [];
                if (reviews.length == 0) {
                    html_text += "<h3>No Reviews found</h3>"
                
                } else {
                    var iter = reviews.length < 5 ?  reviews.length : 5;
                    html_text += "<table border=2 style='border-collapse: collapse; width: 765px'>";
                    for (var x = 0; x < iter; x++) {

                        html_text += "<tr>";
                        html_text += "<td><img style='width:50px;height:50px;' src='" + reviews[x].profile_photo_url + "'></img>" +  "<label style='font-weight:600'>" + reviews[x].author_name + "</label></td>";
                        html_text += "<tr>";
                        html_text += "<td><div style='text-align:left;'>" + reviews[x].text + "</div></tr>"; 
                    }     
                    html_text += "</table>";
                }
                html_text += "</div>";
                
                
                
                // code for showing photos;
                html_text += "<p id='changePhotoHeading'> click to show photos </p>";
                html_text += "<a onclick='showPhotos()'><img id='photo-arrow' style='width:30px;height:20px;' src='http://cs-server.usc.edu:45678/hw/hw6/images/arrow_down.png'></img></a>";
                html_text += "<div id='photos' style='display:none'>";
                
                var photos = 'photos' in jsonDoc.result? jsonDoc.result.photos : [];
                if (photos.length == 0) {
                    html_text += "<h3>No Photos found</h3>"
                
                } else {
                    var iter = photos.length < 5 ? photos.length : 5;
                    html_text += "<table border=2 style='border-collapse: collapse'>";
                    for (var x = 0; x < iter; x++) {
                        html_text += "<tr>";
                        html_text += "<td><a target='_blank' href='/image" + x + ".jpg'><img style='width:700px;height:500px;padding-top: 15px; padding-left: 15px; padding-right: 15px; padding-bottom: 15px;' src='/image" + x + ".jpg'></img></td>";   
                    }
                    html_text += "</table>";
                }
                html_text += "</div>";
            }
            html_text += "</div>"
            var places_list = document.getElementById("places-list");
            places_list.innerHTML = html_text;
        }
    }
</script>

<script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCUGXD_9A8aedwBsDoM9xOWBdbMikYjTzw&callback=initMap">
</script>

<script>
    var map;
    var marker;     
    var orgn_lat;
    var orgn_lng;
    var dest_lat;
    var dest_lng;
    var prev_tdid = '';
    var directionsDisplay;
    var directionsService;
    
    function initMap() {
        var uluru = {lat: -25.363, lng: 131.044};

        map = new google.maps.Map(document.getElementById('map'), {
          zoom: 13,
          center: uluru
        });

        marker = new google.maps.Marker({
          position: uluru,
          map: map
        });
    }
    
    function showMap( lat, lng, tdid ) {

        dest_lat = lat;
        dest_lng = lng;
        var selectedPlace = {lat: lat, lng: lng};

        directionsDisplay = new google.maps.DirectionsRenderer;
        directionsService = new google.maps.DirectionsService;

        marker.setMap(null);
        marker = new google.maps.Marker({
          position: selectedPlace,
          map: map
        });

        var newmap = document.getElementById('map');
        var mapOption = document.getElementById("option");

        if (newmap.style.display !== 'none' && prev_tdid === tdid && prev_tdid !== '') {
            newmap.style.display = 'none';
            mapOption.style.display = 'none';
        }
        else {
            newmap.style.display = 'block';
            mapOption.style.display = 'block';
            prev_tdid = tdid;
        }
        map.setCenter(selectedPlace);
        directionsDisplay.setMap(map)
        
        var tdmap = document.getElementById(tdid);
        var mapOption = document.getElementById("option");

        tdmap.appendChild(newmap);
        tdmap.appendChild(mapOption);
    }       
            
    function calculateDistance(mode) {
        var selectedMode = null;
        if (mode === "walk") {
            selectedMode = "WALKING";

        } else if (mode === "drive") {
            selectedMode = "DRIVING";

        } else if (mode === "bike") {
            selectedMode = "BICYCLING";

        }
      
        directionsService.route({
             origin: {lat: <?php echo $lat ?>, lng: <?php echo $lon ?>},  
             destination: {lat: dest_lat, lng: dest_lng},  
             travelMode: google.maps.TravelMode[selectedMode]
          }, function(response, status) {
             if (status == 'OK') {
                directionsDisplay.setDirections(response);
             } else {
                window.alert('Directions request failed due to ' + status);
             }
        });
   }  
</script>