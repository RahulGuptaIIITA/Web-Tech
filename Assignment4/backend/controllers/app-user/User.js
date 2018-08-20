const axios = require('axios');
const https = require('https');
const util = require('util');
const circularJSON = require('circular-json');
var stringify = require('json-stringify-safe');

module.exports = {
  /**
   * Api call for fetching place list from the google
   */
  places: (req, res) => {
    let latitude = '';
    let longitude = '';
    let keyword = typeof req.body.keyword != 'undefined' ? req.body.keyword : ''
    let distance = typeof req.body.distance != 'undefined' ? req.body.distance : ''
    let category = typeof req.body.category != 'undefined' ? req.body.category : ''
    
    if (req.body.customLoc != '') {
      let url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + encodeURIComponent(req.body.customLoc) + '&key=AIzaSyBzyGygrjfuyoK_UAY2rdvHyCwEVz080lc';
      axios.get(url)
        .then((response) => {
          this.latitude = response.data['results'][0]['geometry']['location']['lat'];
          this.longitude = response.data['results'][0]['geometry']['location']['lng'];

          let url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location='+ this.latitude + ',' + this.longitude + '&'
          url = url + 'radius=' + distance + '&type=' + category + '&keyword=' + keyword + '&key=AIzaSyC2ToTji0g2xZTIBSndY9fXWGS8EhL4X5A';
          axios.get(url)
            .then(places => {
              res.status(200).json(places.data);
            })
            .catch(error => {
              res.status(500).send(error1)
            })
        })
        .catch(error => {
          console.log("Error123");
        })
    
    } else {
      this.latitude = req.body.latitude;
      this.longitude = req.body.longitude;
      let url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location='+ this.latitude + ',' + this.longitude + '&'
      url = url + 'radius=' + distance + '&type=' + category + '&keyword=' + keyword + '&key=AIzaSyC2ToTji0g2xZTIBSndY9fXWGS8EhL4X5A';
      axios.get(url)
        .then(places => {
          res.status(200).json(places.data);
        })
        .catch(error => {
          res.status(500).send(error2)
        })
    }
  },
  
  /**
   * Api call for fetching next page data
   */
  loadNextPageData: (req, res) => {
      
      let token = req.body.token;

      let url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken='+ token + '&key=AIzaSyC2ToTji0g2xZTIBSndY9fXWGS8EhL4X5A';
      axios.get(url)
        .then(places => {
          res.status(200).json(places.data);
        })
        .catch(error => {
          res.status(500).send(error2)
        })
  },

  /**
   * Api call for fetching place details
   */
  loadPlaceDetails: (req, res) => {
    let placeId = req.body.place_id;
    let url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + encodeURIComponent(placeId) + '&key=AIzaSyAjs2WCrzLgGwKE8Epj6Pb0xVlzkkrbeTQ';
    console.log(url);
    axios.get(url)
      .then(places => {
        res.status(200).json(places.data);
      })
      .catch(error => {
        res.status(500).send(error2)
      })
  },

  /**
   * Api call for fetching Yelp Reviews
   */
  loadYelpReviews: (req, res) => {

    console.log(req.body);
    let businessName = typeof req.body.name != 'undefined' ? req.body.name : '';
    let businessCity = typeof req.body.city != 'undefined' ? req.body.city : '';
    let businessState = typeof req.body.state != 'undefined' ? req.body.state : '';
    let businessCountry = typeof req.body.country != 'undefined' ? req.body.country : '';
    let businessAddress = typeof req.body.address != 'undefined' ? req.body.address : '';


    console.log(businessName);
    console.log(businessCity);
    
    let url = 'https://api.yelp.com/v3/businesses/matches/best?name=' + encodeURIComponent(businessName) + '&city=' + encodeURIComponent(businessCity) + '&state=' + encodeURIComponent(businessState) + '&country=' + encodeURIComponent(businessCountry) + '&address1=' + encodeURIComponent(businessAddress);
    
    axios.get(url, {
        headers: {'authorization': 'Bearer Y9kSkqIiZEvMl7hA9LGNEUwjtQ2nTnxc1II7vQ9zcT1U8_kz-6hjNdJIfKD1Ou-Gi802vzH4JOOPUrjbZL1r3TGKbJg_Jlf1FTxFGsKRP1WfxX16EFV6LeXchWzBWnYx'}
      })
      .then((response) => {
          if (response.data.businesses.length == 0) {
              res.status(500).send("zero Results Found");
          }
          let placeId = response.data.businesses[0].id;
          let url = 'https://api.yelp.com/v3/businesses/' + placeId + '/reviews';
          axios.get(url, {
              headers: {'authorization': 'Bearer Y9kSkqIiZEvMl7hA9LGNEUwjtQ2nTnxc1II7vQ9zcT1U8_kz-6hjNdJIfKD1Ou-Gi802vzH4JOOPUrjbZL1r3TGKbJg_Jlf1FTxFGsKRP1WfxX16EFV6LeXchWzBWnYx'}
            })
            .then(reviews => {
              res.status(200).json(reviews.data);
            })
            .catch(error => {
              res.status(500).send(error)
            })
      })
      .catch(error => {
        res.status(500).send(error);
      })
  },

  /**
   * Api call for fetching place details
   */
  loadPlaceDetail: (req, res) => {
    let placeId = req.query.placeId;
    let url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + encodeURIComponent(placeId) + '&key=AIzaSyAjs2WCrzLgGwKE8Epj6Pb0xVlzkkrbeTQ';
    axios.get(url)
      .then(places => {
        res.status(200).json(places.data);
      })
      .catch(error => {
        res.status(500).send(error2)
      })
  }
}