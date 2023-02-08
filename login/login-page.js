const loginAsync = async () =>{
        const res = await githubLogin();
        
        //This is where we create the Cookie. Note the syntax.
		//The JavaScript object we created here is just stuff for me to use later.
        
        Cookies.set('userInfo', {
            username: res.additionalUserInfo.username,
            pfp: (res.additionalUserInfo.profile.avatar_url).toString()+'.png',
            accessToken: res.credential.accessToken

        }, {expires: 29})
        
		//The expires line basically says the cookie expires in 29 days.
	
		//this is not a part of js-cookie but if you're interested, I have a getter and setter with React's useState hook which basically
		//says if it has to redirect to the main content.
        setRedirect(true);
    }
