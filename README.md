# Create and Share...on Rails!

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

## To create filters:

Filters my be added by creating a Yaml file of the same name as the campaign directory.  For example, if the campaign directory is named **picsforpets**, create ```config/filters/picsforpets.yml``` and place the configuration in there.  

A typical filter looks like this:

```
"show-:digit":
  constraints:
    ":digit": "(?<id>[0-9]+)"
  where:
    "id": "id"
```

The above will automatically generate /picsforpets/show/show-*:digit*, where *:digit* is any valid integer.  Notice that under constraints, you specify what a replacement var is with a regular expression.  By using a named callback (e.g. ```(?<id>...)```), we have access to the returned value when we run ```string.match()``` (see next paragraph for how this is used).

The *where* array helps build the query.  For now, all conditions are "=" conditions.  The key specifies the column found in the Post model, and the value specifies a named callback from the regular expression found in constraints.  So the above example will produce something like this:

```ruby
# /picsforpets/show/show-1
Post.where(:id => 1)
```

Alternately, as a slightly more complicated example.

```
":animal_type-:state"
  constraints:
    ":animal_type": "(?<atype>cat|dog|other)s?"
    ":state": "(?<state>[A-Z]{2})"
  where:
    "animal_type": "atype"
    "state": "state"
```

Will automatically generate */picsforpets/show/(cat|dog|other)s?-([A-Z]{2}).  The resulting query will look like:

```ruby
# /picsforpets/show/cats-NY
Post.where(:animal_type => 'cat', :state => 'NY')
```

