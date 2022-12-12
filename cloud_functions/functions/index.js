

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.sendNotifificationOnNewGuest = functions.firestore.document(
    'guests/{guestId}'
).onUpdate((change, _) => {
    var guestData = change.after.data();
    var beforeGuestData = change.before.data();
    if (guestData.lastVisit.seconds > beforeGuestData.lastVisit.seconds) {
        var restaurantReference = admin.firestore().collection('restaurants').doc(guestData.restaurantId);
        restaurantReference.get()
            .then(doc => {
                if (!doc.exists) {
                    console.log('The restaurant does not exist.');
                } else {
                    console.log('Restaurant information:', doc.data());
                    
                    console.log('VIP:', guestData.vip);
                    console.log('BLACKLIST:', guestData.blacklisted);

                    if (guestData.vip || guestData.blacklisted) {
                        var restaurantData = doc.data();
                        var tokens = [];
                        tokens.push(restaurantData.pushNotificationToken);
                        var title = '';
                        if (guestData.vip) {
                            title = 'VIP ALERT';
                        }
                        if (guestData.blacklisted) {
                            title = 'BLACKLIST ALERT';
                        }
                        
                        var bodyMessage = guestData.name + ' has just walked into ' + restaurantData.restaurantName;
                        var payload = {
                            "notification": {
                                "title": title,
                                "body": bodyMessage,
                                "sound": "default"
                            },
        
                            "data": {
                                "sendername": title,
                                "message": bodyMessage,
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                "guestId": change.after.id,
                            }
                        }
                        return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                            console.log('Successfully', tokens);
                            console.log(response);
                            admin.firestore().collection('notifications').add({
                                body: bodyMessage,
                                user: doc.id,
                                datenotification: admin.firestore.FieldValue.serverTimestamp()
                            }).then(ref => {
                                console.log('Added document with ID: ', ref.id);
                                console.log(Date.now().toString());
                            });
                        }).catch((err) => {
                            console.log(err);
                        });
                    }
                
                }
            })
            .catch(err => {
                console.log('Error when getting the restaurant information.', err);
            });
    }
    
})



