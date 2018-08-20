var express = require('express'),
appUserCtrl = require('../controllers/app-user/User'),

router = express.Router()
router.route('/place').post(appUserCtrl.places);
router.route('/loadNextPageData').post(appUserCtrl.loadNextPageData);
router.route('/loadPlaceDetails').post(appUserCtrl.loadPlaceDetails);
router.route('/loadYelpReviews').post(appUserCtrl.loadYelpReviews);
router.route('/loadPlaceDetails').get(appUserCtrl.loadPlaceDetail);

module.exports = router;
