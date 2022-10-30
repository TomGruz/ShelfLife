import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const fcm = admin.messaging();
const fb = admin.firestore();

export const sendToTopic = functions.firestore
    .document("food/{docId}")
    .onWrite((change, context) => {
      let dsnapshot;
      if (change.after.exists) {
        dsnapshot = change.after;
      } else {
        dsnapshot = change.before;
      }
      if (!dsnapshot.exists) {
        return;
      }
      if (dsnapshot.data()!["expiration_date"] == "") {
        console.log("TESTING: new item added to food!");
        const payload: admin.messaging.MessagingPayload = {
          notification: {
            title: "New item added!",
            body: dsnapshot.id,
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        return fcm.sendToTopic("food", payload);
      }
      return;
    });


export const scheduleExpirationActions = functions.firestore
    .document("food/{docId}")
    .onUpdate(async (change, context) => {
      const newValue = change.after.data();
      const oldValue = change.before.data();

      console.log("TEST: modified document id: " + change.after.id);
      if ((newValue["expiration_date"] != oldValue["expiration_date"]) &&
       newValue["expiration_date"] != "") {
        console.log("TEST: executing check of dates...");
        const expirationDate = new Date(newValue["expiration_date"]);
        const currentDate = new Date();
        const alertDays = (1000 * 60 * 60 * 24)*3;
        const alertDate = new Date(expirationDate.getTime() - alertDays);
        if (currentDate > expirationDate) {
          await fb.doc("food/" + change.after.id).update({
            state: "expired",
          });
          console.log("TEST: Sending warning notification to user...");
          const payload: admin.messaging.MessagingPayload = {
            notification: {
              title: newValue["name"] + " has expired",
              body: "Our greatest condolences...",
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
          };

          return fcm.sendToTopic("food", payload);
        } else if (currentDate >= alertDate) {
          await fb.doc("food/" + change.after.id).update({
            state: "warning",
          });
          console.log("TEST: Sending warning notification to user...");
          const payload: admin.messaging.MessagingPayload = {
            notification: {
              title: newValue["name"] + " almost expired!",
              body: "Make some tasty food, quick!",
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
          };
          return fcm.sendToTopic("food", payload);
        }
      }
      return;
    });

