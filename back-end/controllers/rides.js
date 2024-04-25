// created placeholders
// if you add new api handling functions, dont forget to add it to exports at the end :)

const signUpUser = async (req, res) => {

};

const loginUser = async (req, res) => {

};

const getUserDetails = async (req, res) => {

};

const modifyUserDetails = async (req, res) => {

};

const submitRide = async (req, res) => {

};

const findRides = async (req, res) => {
    const response = {
        message : "Hello World!!"
    };
    console.log(req.body);
    res.status(200).json(response);
};

const getRideDetails = async (req, res) => {

};

const confirmRide = async (req, res) => {

};

module.exports = {
  signUpUser,
  loginUser,
  getUserDetails,
  modifyUserDetails,
  submitRide,
  findRides,
  getRideDetails,
  confirmRide,
};
