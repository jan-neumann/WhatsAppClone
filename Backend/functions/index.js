/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');
const {onRequest} = require("firebase-functions/v2/https");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Next Level Deployment! Again.");
// });

const channelMessageRef = "/channel-messages/{channelId}/{messageId}"

exports.listenForNewMessages = functions.database
    .ref(channelMessageRef)
    .onCreate(async (snapshot, context) => {
        const data = snapshot.val()
        const channelId = context.params.channelId
        const message = data["text"]
        const ownerUid = data["ownerUid"]

        // Get the message sender name
        const messageSenderSnapshot = await admin
        .database()
        .ref("/users/" + ownerUid)
        .once("value")
        
        const messageSenderDict = messageSenderSnapshot.val()
        const senderName = messageSenderDict["username"]

        await getChannelMembers(channelId, message, senderName)
});

// Get the Channel Members
async function getChannelMembers(channelId, message, senderName) {
    const channelSnapshot = await admin
    .database()
    .ref("/channels/" + channelId)
    .once("value")

    const channelDict = channelSnapshot.val()
    const membersUids = channelDict["membersUids"]

    for (const userUId of membersUids) {
        await getUserFCMToken(message, userUId, senderName)
    }
}

// Get the FCMToken for each channel member
async function getUserFCMToken(message, userId, senderName) {
    const userSnapshot = await admin
    .database()
    .ref("/users/" + userId)
    .once("value")

    const userDict = userSnapshot.val();
    const fcmToken = channelDict["fcmToken"]

    await sendPushNotifications(message, senderName, fcmToken);
}

// Send push notification from cloud functions using APNS
async function sendPushNotifications(message, senderName, fcmToken) {
    const payload = {
        notification: {
            title: senderName,
            body: message,
        },
        apns: {
            payload: {
                aps: {
                    sound: "default",
                    badge: 7,
                },
            },
        },
        token: fcmToken,
    }

    try {
        await admin.messaging().send(payload);
        console.info("Successfully sent message: ", message)
    } catch (error) {
        console.error("Error sending message: ", error)
    }
}