import * as moment from 'moment'
import { Headers, Http } from '@angular/http';
import {NgbModule} from '@ng-bootstrap/ng-bootstrap';
import { ChangeDetectionStrategy, Component, OnInit, Input, ElementRef, ViewChild, EventEmitter, Output } from '@angular/core';

type PaneType = 'left' | 'right';

@Component({
  selector: 'app-placedetails',
  templateUrl: './placedetails.component.html',
  styleUrls: ['./placedetails.component.css']
})

export class PlacedetailsComponent implements OnInit {

  @Input() detailMapBody;
  @Input() placeDetail: any = [];
  @Input() favoritePlaces: any = [];
  @Input() showResult:Boolean = true;
  @Input() showFavorite: Boolean = true;
  @Output() backToList = new EventEmitter<any>();
  
  private reviews: any = [];
  private ratings: any = [];
  private placeIdArr: any = [];
  private twitterUrl: any = '';
  private pricelevel: any = [];
  private photosCols: any = [];
  private completeRow: any = 0;
  private incompleteRow: any = 0;
  private yelpReviews: any = [];
  private modalTimings: any = [];
  private openNow: number = 0;
  private zeroPhotos: boolean = false;
  private isFavorite: boolean = false;
  private showMapDiv: boolean = false;
  private showInfoDiv: boolean = true;
  private sortType: string = 'default';
  private sortString: string = "Deafult Order";
  private reviewString: string = "Google Review";
 
  private reviewType: string = 'google';
  private showChildList: boolean = true;
  private showPhotosDiv: boolean = false;
  private showReviewsDiv: boolean = false;
  private showParentList: boolean = false;
  private showTimingModel: boolean = false;
  private getDirectionDisable: boolean = false;
  private defaultGoogleReviews: any = [];
  private defaultYelpReviews: any = [];

  private zeroYelp: boolean = false;
  private zeroGoogle: boolean = false;


  private mapVal: any = {
    'from': '',
    'travelMode': 'DRIVING'
  };
  private map: any = null;
  private marker: any = null;
  private showPegmanIcon: boolean = true;
  private showMapsIcon: boolean = false;
  private directionsDisplay: any = null;
  private directionsService: any = null;

  private firstColumn: any = [];
  private thirdColumn: any = [];
  private secondColumn: any = [];
  private fourthColumn: any = [];

  @ViewChild("autocomp") autocompV: ElementRef;
  @ViewChild("googleMap") googlemap: ElementRef;
  @ViewChild("googleMapPanel") googlemapPanel: ElementRef;

  constructor(private http: Http) {
  }

  ngOnInit() {
    console.log(this.placeDetail);
    let url = "";
    let text = "Check	out " + this.placeDetail.name + " located	at " + this.placeDetail.formatted_address + ". Website:	";

    if (this.placeDetail.website) {
      url = this.placeDetail.website;
      text = text + this.placeDetail.website;
    } else {
      url = this.placeDetail.url;
      text = text + this.placeDetail.url;
    }
    text = text + " #TravelAndEntertainmentSearch";
    this.twitterUrl = 'http://twitter.com/intent/tweet?text=' + encodeURIComponent(text);

    this.setPriceLevel();
    this.setPlaceStarRating();
    this.getYelpReviews();
    this.defaultGoogleReviews = Object.assign([], this.placeDetail.reviews);

    if (this.defaultGoogleReviews.length == 0) {
        this.zeroGoogle = true;
    }
    
    if (this.placeDetail.hasOwnProperty('opening_hours')) {
      if (this.placeDetail.opening_hours.open_now) {
        this.openNow = 1;
      } else {
        this.openNow = 2;
      }
    } 

    if (this.detailMapBody.loc == "") {
      this.mapVal.from = "Your Location";
    } else {
      this.mapVal.from = this.detailMapBody.loc;
    }

    this.placeIdArr = JSON.parse(localStorage.getItem('favorite_arr'));
    if (this.placeIdArr != null) {
      for ( let id of this.placeIdArr) {
        if ( id == this.placeDetail.place_id) {
            this.isFavorite = true;
        }
      }
    }
  }

  setPriceLevel() {
    this.pricelevel = Array(this.placeDetail.price_level).fill(4);
  }

  setPlaceStarRating() {
    //http://blog.bastien-donjon.fr/round-number-angular-2-pipe/
    let len = this.placeDetail.rating ? Math.floor(this.placeDetail.rating) : 0;
    this.ratings = Array(len).fill(4);
  }

  showInfo() {
    this.showMapDiv = false;
    this.showInfoDiv = true;
    this.showPhotosDiv = false;
    this.showReviewsDiv = false;
  }

  openModal() {
    this.modalTimings = [];
    this.showTimingModel = true;
    if (this.placeDetail.hasOwnProperty('opening_hours')) 
    {
      for (let timing of this.placeDetail.opening_hours.weekday_text) {
        let time = timing.split(': ');
        this.modalTimings.push(
          {
            'day': time[0],
            'time': time[1]
          }
        );
      }
    } else {
      console.log("hola");
    }
  }
  
  closeModal() {
    this.showTimingModel = false;
  }

  showList() {
    this.showChildList = false;
    this.showParentList = true;
    this.backToList.emit("back");
  }
  
  showPhotos() {
    this.showMapDiv = false;
    this.showInfoDiv = false;
    this.showPhotosDiv = true;
    this.showReviewsDiv = false;

    if (this.placeDetail.hasOwnProperty('photos') && this.placeDetail['photos'].length > 0) {
      this.zeroPhotos = false;
    } else {
      this.zeroPhotos = true;
    }
    
    let i: number = 1;
    for (let photo of this.placeDetail['photos']) {
      let url = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=' + photo.width + '&photoreference=' + photo.photo_reference + '&key=AIzaSyCBySLe96XKPFJr3NhJrpwaSMp_2inmaL4';
      
      if (i%4 == 1) {
        this.firstColumn.push(url);
      } else if (i%4 == 2) {
        this.secondColumn.push(url);
      } else if (i%4 == 3) {
        this.thirdColumn.push(url);
      } else if (i%4 == 0) {
        this.fourthColumn.push(url);
      }
      i = i + 1;
    }
  }

  showKeywordWarning() {
		if (this.autocompV.nativeElement.value && this.autocompV.nativeElement.value.replace(/\s/g, '').length) {
			if (this.autocompV.nativeElement.value < 3) {
				this.getDirectionDisable = true;
			} else {
				this.getDirectionDisable = false;
			}
		} else {
			this.getDirectionDisable = true;
		}
  }
  
  getDirections() {
    let fromLoc = this.autocompV.nativeElement.value;
    
    if (fromLoc == "Your Location") {
      fromLoc = { lat: this.detailMapBody.lat, lng: this.detailMapBody.lon }
    } 
    
    this.directionsService.route({
      origin: fromLoc,
      destination: { lat: this.placeDetail.geometry.location.lat, lng: this.placeDetail.geometry.location.lng },
      travelMode: this.mapVal.travelMode,
      provideRouteAlternatives: true
    }, function (response, status) {
      if (status == 'OK') {
        this.directionsDisplay.setDirections(response);
      } else {
      }
    }.bind(this));
  }

  showMap() {
    this.showMapDiv = true;
    this.showInfoDiv = false;
    this.showPhotosDiv = false;
    this.showReviewsDiv = false;

    let autocomplete = new google.maps.places.Autocomplete(this.autocompV.nativeElement, {
      types: ['address']
    });
    
    var uluru = { lat: this.placeDetail.geometry.location.lat, lng: this.placeDetail.geometry.location.lng };

    this.map = new google.maps.Map(this.googlemap.nativeElement, {
      zoom: 13,
      center: uluru
    });

    this.marker = new google.maps.Marker({
      position: uluru,
      map: this.map
    });

    this.directionsDisplay = new google.maps.DirectionsRenderer;
    this.directionsService = new google.maps.DirectionsService;
    this.directionsDisplay.setMap(this.map);
    this.directionsDisplay.setPanel(this.googlemapPanel.nativeElement);
  }

  showPegman() {
    this.showPegmanIcon = false;
    this.showMapsIcon = true;
    var uluru = {lat: this.placeDetail.geometry.location.lat, lng: this.placeDetail.geometry.location.lng };
    var panorama = new google.maps.StreetViewPanorama(
          this.googlemap.nativeElement, {
          position: uluru,
          pov: {
            heading: 34,
            pitch: 10
          }
    });
    this.map.setStreetView(panorama);
  }
  showMapIcon() {
    this.showPegmanIcon = true;
    this.showMapsIcon = false;
    this.showMap();
  }
  /*
    hs to be refined
  */
  addFavorites(place) {

    this.placeIdArr = JSON.parse(localStorage.getItem('favorite_arr'));

    if (!this.placeIdArr) {
      this.placeIdArr = [place.place_id];
    } else {
      this.placeIdArr.push(place.place_id);
    }
    this.isFavorite = true;
    this.favoritePlaces.push(place);
    localStorage.setItem('favorite_arr', JSON.stringify(this.placeIdArr));
  }

  removeFavorite(place) {
    let tempFavPlace: any = [];
    console.log(this.favoritePlaces.length);
		for (let p of this.favoritePlaces) {
				if (p.place_id != place.place_id) {
					  tempFavPlace.push(place);
				}
    }
    this.isFavorite = false;
    this.favoritePlaces = Object.assign([], tempFavPlace);
    console.log(this.favoritePlaces.length);
    this.placeIdArr = this.placeIdArr.filter((value) => value != place.place_id);
    localStorage.setItem('favorite_arr', JSON.stringify(this.placeIdArr));
	}

  showReviews() {
    this.showMapDiv = false;
    this.showInfoDiv = false;
    this.showPhotosDiv = false;
    this.showReviewsDiv = true;

    if (this.reviewType == "google") {
      this.reviews = this.placeDetail.reviews;
      if (this.sortType == "lowest") {
        this.reviews.sort(function (r1, r2) {
          if (r1.rating < r2.rating) {
            return -1;
          } else if (r1.rating > r2.rating) {
            return 1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "highest") {
        this.reviews.sort(function (r1, r2) {
          if (r1.rating < r2.rating) {
            return 1;
          } else if (r1.rating > r2.rating) {
            return -1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "least") {
        this.reviews.sort(function (r1, r2) {
          if (r1.time < r2.time) {
            return -1;
          } else if (r1.time > r2.time) {
            return 1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "most") {
        this.reviews.sort(function (r1, r2) {
          if (r1.time < r2.time) {
            return 1;
          } else if (r1.time > r2.time) {
            return -1;
          } else {
            return 0;
          }
        });
      } else {
        this.reviews = this.defaultGoogleReviews;
      }
    }

    else if (this.reviewType == "yelp") {
      if (this.yelpReviews.length == 0) {
          this.zeroYelp = true;
      }
      this.reviews = [];
      if (this.sortType == "lowest") {
        this.yelpReviews.sort(function (r1, r2) {
          if (r1.rating < r2.rating) {
            return -1;
          } else if (r1.rating > r2.rating) {
            return 1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "highest") {
        this.yelpReviews.sort(function (r1, r2) {
          if (r1.rating < r2.rating) {
            return 1;
          } else if (r1.rating > r2.rating) {
            return -1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "least") {
        this.yelpReviews.sort(function (r1, r2) {
          if (moment(r1.time_created).isAfter(r2.time_created)) {
            return 1;
          } else if (moment(r2.time_created).isAfter(r1.time_created)) {
            return -1;
          } else {
            return 0;
          }
        });
      } else if (this.sortType == "most") {
        this.yelpReviews.sort(function (r1, r2) {
          if (moment(r1.time_created).isAfter(r2.time_created)) {
            return -1;
          } else if (moment(r2.time_created).isAfter(r1.time_created)) {
            return 1;
          } else {
            return 0;
          }
        });
      }  else {
        this.yelpReviews = this.defaultYelpReviews;
      }
    }
  }

  /* *
	 * Call for fetching yelp reviews.
	 * 
	 */
  getYelpReviews() {
    let city = '';
    let name = '';
    let state = '';
    let country = '';
    let address = '';
    name = this.placeDetail.name;
    address = this.placeDetail.formatted_address;

    for (let component of this.placeDetail.address_components) {
      let types = component['types'];
      if (types.indexOf("country") >= 0) {
        country = component.short_name;
      } else if (types.indexOf("administrative_area_level_1") >= 0) {
        state = component.short_name;
      } else if (types.indexOf("administrative_area_level_2") >= 0) {
        city = component.short_name;
      }
    }

    let body = {
      'name': name,
      'city': city,
      'state': state,
      'country': country,
      'address': address
    };

    this.fetchingYelpReviews(body).subscribe(data => {
      if (data.hasOwnProperty('reviews') && data.reviews.length > 0) {
          this.yelpReviews = data.reviews;
          this.defaultYelpReviews = Object.assign([], data.reviews);
      }
    });
  }

  fetchingYelpReviews(body) {
    let headers = new Headers();
    headers.append('Content-Type', 'application/json');

    let apiEndURL = "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/loadYelpReviews";

    return this.http.post(apiEndURL, JSON.stringify(body), { headers: headers })
      .map(res => res.json());
  }
}
