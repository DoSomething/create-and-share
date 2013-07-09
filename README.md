=Create and Share...on Rails!

Create and Share is a campaign model used on DoSomething.org.  Users are encouraged to upload a picture and provide some basic details that will show up on an infinite scroll gallery.  The gallery provides multiple search filters to show certain posts.

## To create a new campaign: 

1. Visit /campaigns/new as an administrator (if you're not an admin, it'll ask you to log in).  Fill out the form as appropriate.  All fields are required.
2. The path specified in step 1 will be automatically generated in the routes file, along with a number of generic routes:  
```
/:campaign/submit         # Submit page
/:campaign/faq            # FAQ
/:campaign/start          # Submit guide
/:campaign/gallery        # Static (closed) gallery page*
/:campaign/:id            # Single post view
/:campaign/:id/flag       # Flag a post (admin only)
/:campaign/posts/:id/edit # Edit a post (admin only)
/:campaign/featured       # Promoted posts view
/:campaign/mine           # Pets that the user submitted / shared
/:campaign/:vanity        # Searches for a promoted pet of the name specified by :vanity
```
3. You can create / add filters by (TODO).
