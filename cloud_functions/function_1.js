const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
admin.initializeApp();
// database is realtime database
const database = admin.database();
// db is firestore
const db = admin.firestore();
exports.newValueDetected = functions.database.ref("{valueType}/value")
	.onWrite(async (change, context) => {
  	const oldValue = change.before.val();
  	const valueAfter = change.after.val();
  	const valueType = context.params.valueType;
  	const reff = database.ref("metadata/lastChangedVal/");
  	reff.set(valueAfter + " was " + oldValue + " type " + valueType);
  	if (valueType == "barcode") {
    	const waitingBarcode = database.ref("waitingData/waitingBarcode/");
    	waitingBarcode.set(valueAfter);
  	}
  	if (valueType == "weight") {
    	const waitingWeight = database.ref("waitingData/waitingWeightDifference/");
    	waitingWeight.set(valueAfter-oldValue);
  	}
  	if (valueType == "button") {
    	const waitingButton = database.ref("waitingData/waitingButton/");
    	waitingButton.set(valueAfter);
  	}
  	const ref = database.ref("waitingData");
  	ref.on("value", async (snapshot) => {
    	const aa = snapshot.val().waitingBarcode;
    	const bb = snapshot.val().waitingWeightDifference;
    	const cc = snapshot.val().waitingButton;
    	if (aa != "" && bb > 0) {
      	// check if doc in collection
      	const doc = await db.collection("food").doc(aa).get();
      	if (!doc.exists) {
        	const imageLinkJSON = ["https://world.openfoodfacts.org/api/v0/product/", aa, ".json"].join("");
        	(async () => {
          	try {
            	const res = await fetch(imageLinkJSON);
            	const data = await res.json();
            	db.collection("food").doc(aa).set({name: data.product["product_name"], weight: String(bb), expiration_date: "", state: "ok", on_shelf: true, image_url: data.product["image_front_url"]});
          	} catch (err) {
            	db.collection("food").doc(aa).set({name: "err"});
          	}
        	})();
        	database.ref("waitingData/waitingBarcode/").set("");
        	database.ref("waitingData/waitingWeightDifference/").set(0);
        	database.ref("waitingData/waitingButton/").set(3);
        	database.ref("barcode/value/").set("");
      	} else {
      	// the barcode already exisists in the collection
        	if (cc == 3) {
        	// the item was not on the shelf moments ago == it is sealed => you have to ask for expDate
          	db.collection("food").doc(aa).update({weight: String(bb), expiration_date: "", state: "ok", on_shelf: true});
          	database.ref("waitingData/waitingBarcode/").set("");
          	database.ref("waitingData/waitingWeightDifference/").set(0);
          	database.ref("waitingData/waitingButton/").set(3);
          	database.ref("barcode/value/").set("");
        	} else {
              db.collection("food").doc(aa).update({weight: String(bb), on_shelf: true});
          	database.ref("waitingData/waitingBarcode/").set("");
          	database.ref("waitingData/waitingWeightDifference/").set(0);
          	database.ref("waitingData/waitingButton/").set(3);
          	database.ref("barcode/value/").set("");
        	}
      	}
    	}
    	if (bb < 0 && aa != "") {
      	db.collection("food").doc(aa).update({on_shelf: false});
      	database.ref("waitingData/waitingBarcode/").set("");
      	database.ref("waitingData/waitingWeightDifference/").set(0);
      	database.ref("waitingData/waitingButton/").set(3);
      	database.ref("barcode/value/").set("");
    	}
  	});
  	return valueAfter;
	});

