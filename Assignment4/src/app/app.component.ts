import { Http, Headers } from '@angular/http';
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { Observable } from 'rxjs';
import {} from '@types/googlemaps';

import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';


@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.css']
})

export class AppComponent implements OnInit {

	private isLoading = false;
	private isDisabled = true;
	private showResult = true;
	private showFavorite = false;
	private showProgressBar = false;
	private modelLocation = "automatic";

	private lat: any = null;
	private lon: any = null;
	private inputs: any = {};
	private currentIp: any = {};
	private mapBodyJson:any = {};
	private placesList: any = [];
	private listIndex: number = 0;
	private nextPageToken: any = null;
	private zeroResult: boolean = false;
	
	@ViewChild("autocomp") autocompV: ElementRef;

	constructor(private http: Http) {
		localStorage.removeItem('favorite_arr');
		localStorage.removeItem('highlighted_detail');
	}

	ngOnInit() {

		this.inputs.category = "default";
		let url = "http://ip-api.com/json/";
		this.http.get(url).subscribe(
			(result) => {
				this.currentIp = result.json();
				this.lat = this.currentIp['lat'];
				this.lon = this.currentIp['lon'];
			}
		)
	}

	trig(e) {
		this.searchPlace();
	}
	clear() {
		this.inputs = {};
		this.zeroResult = false;
		localStorage.removeItem('highlighted_detail');
		this.isLoading = false;
	}

	showKeywordWarning() {
		if (this.inputs.keyword && this.inputs.keyword.replace(/\s/g, '').length) {
			if (this.inputs.keyword.length < 3) {
				return true;
			} else {
				return false;
			}
		} else {
			return true;
		}
	}
	showLocationWarning() {
		if (this.modelLocation == "google") {
			if (!this.inputs.customLoc) {
				return true;
				
			} else if (this.inputs.customLoc && this.inputs.customLoc.replace(/\s/g, '').length == 0) {
				return true;
			}
		}

		return false;
	}

	locationSet() {
		if (this.modelLocation == "google" && this.inputs.customLoc) {
			return true;
		} else if (this.lat && this.lon) {
			return true;
		}

		return false;
	}

	checkSearchButton() {
		if (this.inputs.keyword && this.locationSet()) {
			return true;
		}

		return false;
	}

	enableLocationTextbox() {
		this.isDisabled = false;
	}

	disableLocationTextbox() {
		this.inputs.customLoc = '';
		this.isDisabled = true;
	}

	getData(body) {
		let headers = new Headers();
		headers.append('Content-Type', 'application/json');

		let apiEndURL = "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/place";

		return this.http.post(apiEndURL, body, { headers: headers })
			.map(res => res.json());
	}

	searchPlace() {

		this.showProgressBar = true;
		this.showResult = true;
		this.showFavorite = false;

		let body = {
			keyword: this.inputs.keyword,
			category: this.inputs.category,
			distance: this.inputs.distance ? this.inputs.distance * 1609 : 16090,
			customLoc: '',
			latitude: '',
			longitude: ''
		};
		this.mapBodyJson = {
			'lat': this.lat,
			'lon': this.lon,
			'loc': ''
		}
		if (this.modelLocation == "google") {
			body.customLoc = this.autocompV.nativeElement.value;
			this.mapBodyJson.loc = this.autocompV.nativeElement.value;
		} else {
			body.latitude = this.lat,
			body.longitude = this.lon
		}

		this.getData(JSON.stringify(body)).subscribe(data => {
			this.showProgressBar = false;
			if (data.status == "OK") {
				this.isLoading = true;
				this.placesList = data.results;
				this.zeroResult = false;
				let favoriteArr = JSON.parse(localStorage.getItem('favorite_arr'));
				let tempPlace: any = [];
				if (favoriteArr != null && favoriteArr.length != 0) {
					for (let place of this.placesList) {
						let flag: boolean = false;
						for ( let id of favoriteArr) {
							if (id == place.place_id) {
								flag = true;
								break;
							}
						}
						if (flag) {
							console.log("seetimg true for " + place.place_id);
							place.star = true;
						} else {
							place.star = false;
						}
						tempPlace.push(place);
					}
					this.placesList = tempPlace;
				}
				this.nextPageToken = data.next_page_token;
			} else {
				this.zeroResult = true;
			}
		});
	}

	showFavorites() {
		this.showResult = false;
		this.showFavorite = true;
	}
}