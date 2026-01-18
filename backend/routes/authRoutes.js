const express = require("express");
const bcrypt = require("bcryptjs");
const User = require("../models/User");

const router = express.Router();


router.post("/register", async (req, res) => {

  try {
        const { username, email, password } = req.body;
        console.log("REGISTER HIT", req.body);
  
        // Check if email already exists
        const existingUser = await User.findOne({ email: email.toLowerCase() });
        if (existingUser) {
          return res.status(400).json({
            success: false,
            error: "Email already registered",
          });
        }
        const user = await User.create({ username, email, password });
  
        res.status(201).json({
          userId:user._id,
          username :user.username
        });
      } catch (error) {
        res.status(500).json({
          error: error.message,
        });
      }
    }
);


router.post("/login", async (req, res) => {
 try {
       const { email, password } = req.body;
 
       const user = await User.findOne({ email: email.toLowerCase() });
       if (!user) {
         return res.status(404).json({
           error: "Invalid email or password",
         });
       }
       const isMatch = await user.comparePassword(password);
       if (!isMatch) {
         return res.status(400).json({
           error: "Invalid email or password",
         });
       }
 
 
 res.json({
   userId:user._id,
   username:user.username,

 });
 
     } catch (error) {
       res.status(500).json({
         success: false,
         error: error.message,
       });
     }
   });

module.exports = router;
