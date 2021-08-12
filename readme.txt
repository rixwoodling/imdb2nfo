# imdb2nfo

This is a shell script that parses movie information from IMDB and outputs an XML-styled .nfo that can be read by Kodi. 


### prerequisites ###

# - basic command line navigation skills on either terminal, putty, tmux, etc...
# - this shell script has been fully tested to work with bash and zsh shells.
# - this script requires 'curl' to pull information from imdb https servers.
# - no APIs are required so it remains light and portable. 


### installation ###

# - first, either download the zip or 'git clone' this to your local computer. 
    https://github.com/rixwoodling/imdb2nfo/archive/refs/heads/master.zip
    git clone https://github.com/rixwoodling/imdb2nfo.git
    
# - then, navigate to 'imdb2nfo.sh'. for example, if you unzipped this to your desktop:
    cd ~/Desktop/imdb2nfo/

# - if you need to set executable permissions, run:
    chmod +x ~/Desktop/imdb2nfo/imdb2nfo.sh

# - then, run:
    ./imdb2nfo.sh

# - if you see 'enter imdb id: tt ', it's ready to use.


### using imdb2nfo ###




End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
