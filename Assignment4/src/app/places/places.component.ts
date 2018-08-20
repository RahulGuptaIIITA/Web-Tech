import { Headers, Http } from '@angular/http';
import { Component, OnInit, Input, EventEmitter, Output } from '@angular/core';
import { trigger, state, style, transition, animate, keyframes } from '@angular/animations';

@Component({
	selector: 'app-places',
	templateUrl: './places.component.html',
	styleUrls: ['./places.component.css'],
	animations: [
		trigger(
		  'myAnimation',
		  [
			transition(
			':enter', [
			  style({transform: 'translateX(100%)', opacity: 0}),
			  animate('500ms', style({transform: 'translateX(0)', 'opacity': 1}))
			]
		  ),
		  transition(
			':leave', [
			  style({transform: 'translateX(0)', 'opacity': 1}),
			  animate('500ms', style({transform: 'translateX(100%)', 'opacity': 0})),
			  
			]
		  )]
		)
	  ],
})

export class PlacesComponent implements OnInit {
	
	private detailMap: any = {};
	private placeIdArr: any = [];
	private placesCopy: any = [];
	private isLeftVisible = false;
	private placeDetails: any = {};
	private combinedPlaces: any = [];
	private favoritePlaces: any = [];
	private favoritePlacesCache: any = [];
	private startToggle: Boolean = false;
	private showPlaceDetails: boolean = false;
	private highlightedDetailElement: any = '';
	private nextPageTokenCopy: any = '';

	@Input() mapBody;
	@Input() places: any = [];
	@Input() listIndex: number = 0;
	@Input() nextPageToken: any = [];
	@Input() showResult: boolean = true;
	@Input() showFavorite: boolean = false;
	@Output() triggerButton = new EventEmitter<any>();
	
	constructor(private http: Http) { }

	ngOnInit() {
		this.detailMap = this.mapBody;
		this.placesCopy = this.places;
		this.nextPageTokenCopy = this.nextPageToken;
		this.highlightedDetailElement = localStorage.getItem('highlighted_detail');
		this.favoritePlacesCache = JSON.parse(localStorage.getItem('favorite_arr'));
	}

	/**
	 * Utility functions
	 *  
	 */
	addFavorites(place, index) {
		this.placesCopy[index].star = typeof this.placesCopy[index].star == 'undefined' ? true : !this.placesCopy[index].star;
		if (this.placeIdArr.indexOf(place.place_id) == -1) {
			place.star = this.placesCopy[index].star;
			this.placeIdArr.push(place.place_id);
			this.favoritePlaces.push(place);
		} else {
			this.removeFavorite(place);
			this.placeIdArr = this.placeIdArr.filter((value) => value != place.place_id);
		}
		localStorage.setItem('favorite_arr', JSON.stringify(this.placeIdArr));
	}

	removeFavorite(place) {
		this.placeIdArr = this.placeIdArr.filter((value) => value != place.place_id);
		localStorage.setItem('favorite_arr', JSON.stringify(this.placeIdArr));
		
		let tempFavPlace: any = [];
		for (let place of this.favoritePlaces) {
			for ( let id of this.placeIdArr) {
				if (id == place.place_id) {
					tempFavPlace.push(place);
				}
			}
		}
		let tempPlace = [];
		for (let p of this.placesCopy) {
			if (p.place_id == place.place_id) {
				p.star = false;
			}
			tempPlace.push(p);
		}
		this.placesCopy = tempPlace;
		this.favoritePlaces = Object.assign([], tempFavPlace);
	}

	searchPrev() {
		if (this.listIndex <= 0) {
			this.placesCopy = [];
			this.listIndex = this.listIndex + 1;
		} else {
			this.placesCopy = this.combinedPlaces[this.listIndex -1];
			this.listIndex = this.listIndex - 1;
		}
	}

	list(e) {
		this.highlightedDetailElement = localStorage.getItem('highlighted_detail');
		this.showPlaceDetails = false;
		this.showResult = true;
		this.triggerButton.emit("abc");
		if (this.listIndex > 0) {
			this.placesCopy = this.combinedPlaces[this.listIndex];
		}

		let favoriteArr = JSON.parse(localStorage.getItem('favorite_arr'));
		let tempPlace: any = [];
		if (favoriteArr != null && favoriteArr.length != 0) {
			for (let place of this.placesCopy) {
				let flag: boolean = false;
				for ( let id of favoriteArr) {
					if (id == place.place_id) {
						flag = true;
						break;
					}
				}
				if (flag) {
					place.star = true;
				} else {
					place.star = false;
				}
				tempPlace.push(place);
			}
			this.placesCopy = tempPlace;
		}
	}
	
	/* *
	 * Call for fetching next page data.
	 * 
	 */
	searchNext() {
		if (this.nextPageTokenCopy) {
			this.getNextPageData().subscribe(data => {
				if (data.status == "OK") {
					this.combinedPlaces[this.listIndex] = this.placesCopy;
					this.placesCopy = data.results;
					this.nextPageTokenCopy = data.next_page_token;
					this.listIndex += 1;
					this.combinedPlaces[this.listIndex] = this.placesCopy;
				}
			});
		} else {
			this.placesCopy = this.combinedPlaces[this.listIndex + 1]
			this.listIndex = this.listIndex + 1;
		}
	}

	updateFavorites() 
	{
		let favoriteArr = JSON.parse(localStorage.getItem('favorite_arr'));
		let tempFavPlace: any = [];
		if (favoriteArr != null && favoriteArr.length != 0) {
			for (let place of this.favoritePlaces) {
				let flag: boolean = false;
				for ( let id of favoriteArr) {
					if (id == place.place_id) {
						flag = true;
						break;
					}
				}
				if (flag) {
					tempFavPlace.push(place);
				}
			}
			this.favoritePlaces = tempFavPlace;
		}

		return true;
	}
	
	getNextPageData() {
		let headers = new Headers();
		headers.append('Content-Type', 'application/json');

		let apiEndURL = "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/loadNextPageData";

		let body = { 'token': this.nextPageTokenCopy };

		return this.http.post(apiEndURL, JSON.stringify(body), { headers: headers })
			.map(res => res.json());
	}

	/* *
	 * Call for fetching place details data.
	 * 
	 */
	moreDetail(placeId) {
		this.isLeftVisible = !this.isLeftVisible;
		localStorage.setItem('highlighted_detail', placeId);
		this.fetchDetailData(placeId).subscribe(data => {
			if (data.status == "OK") {
				this.placeDetails = data.result;
				this.showPlaceDetails = true;
				this.showResult = false;
				this.showFavorite = false;
			}
		});
	}

	fetchDetailData(placeId) {
		let headers = new Headers();
		headers.append('Content-Type', 'application/json');

		let apiEndURL = "http://hw8v1.us-east-1.elasticbeanstalk.com/web-api/loadPlaceDetails";

		let body = { 'place_id': placeId };

		return this.http.post(apiEndURL, JSON.stringify(body), { headers: headers })
			.map(res => res.json());
	}
}