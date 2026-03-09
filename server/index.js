require('dotenv').config(); 
const express=require("express");
var http =require("http");
const app =express();
const port= process.env.PORT||3000;
const mongoose=require("mongoose");
const getWord = require('./api/getWord');
const Room = require("./models/Room"); 

var server=http.createServer(app);
var socket=require("socket.io");
var io=socket(server);

//middleware
app.use(express.json());    

//connect to our MongoDB
const DB= process.env.MONGO_URI
mongoose.connect(DB).then(()=>{
    console.log('Connection successful!');
}).catch((e)=>{
    console.log(e);
});

io.on('connection',(socket)=>{
    console.log('connected');


//create game call back 
    socket.on('create-game',async({nickname,name,occupancy,maxRounds})=>{
/* 
socket.on('create-game', async (data)=>{

const nickname = data.nickname;
const name = data.name;
const occupancy = data.occupancy;
const maxRounds = data.maxRounds;

});
*/

        try {
            const existingRoom=await Room.findOne({name});
            if(existingRoom){
                socket.emit('notCorrectGame','Room with that name already exists !');
                return;
            }
            let room=new Room();
            const word =getWord();
            room.word=word;
            room.name=name;
            room.occupancy = Number(occupancy);
            room.maxRounds = Number(maxRounds);
            room.isJoin = true;

            let player={
                socketID:socket.id,
                nickname,
                isPartyLeader:true
            }
            room.players.push(player);
            room=await room.save();
            socket.join(name);
            io.to(name).emit('updatedRoom',room);
        } catch (err) {
            console.log(err);
        }
    });

    //Join game callback  
    socket.on('join-game',async({nickname,name})=>{
        try {
            let  room=await Room.findOne({name});
            if(!room){
                socket.emit("notCorrectGame","Please enter a valid roomName");
                return;
            }
            if(room.isJoin){
                let player={
                    socketID:socket.id,
                    nickname
                }
                room.players.push(player);
                socket.join(name);
                if(room.players.length===room.occupancy){
                    room.isJoin=false;
                }

                room.turn=room.players[room.turnIndex];
                room=await room.save();
                io.to(name).emit('updatedRoom',room);
                
            }else{
     socket.emit("notCorrectGame","The game is in progress,please try later!");

            }
        } catch (err) {
            console.log(err);
        }
    })

    socket.on('msg',async(data)=>{
        try {
            io.to(data.roomName).emit('msg',{
                username:data.username,
                msg:data.msg,
            })
        } catch (err) {
            console.log(err.toString());
        }
    })
});






server.listen(port,"0.0.0.0",()=>{
    console.log('Server started and running on port' +port);
})
