Othello Minimax
=============

Othello game in OCaml (player versus IA using Minimax Alpha-Beta or Random)

[Rules on Wikipedia](http://en.wikipedia.org/wiki/Reversi)

![Screenshot](https://dl.dropbox.com/u/18506317/images/ocaml_minimax.png)


## Installation

	1 - `$ git clone git://gitorious.org/othello-minimax/othello-minimax.git` Clone the project using git

or download the package : [othello-minimax.tar.gz](https://gitorious.org/othello-minimax/othello-minimax/archive-tarball/master)

	1 - `$ tar -zxvf othello-minimax-othello-minimax-master.tar.gz -C othello-minimax` Unzip the archive
	
	2 - `$ cd othello-minimax/` 
	3 - `$ make` Build the binaries
	4 - `./othello` Run the application
	
## Options
```
othello
  -cellsize <int> : Set cell size in pixels
  -size <int> : Set Board length
  -ia <bool> : Artificial intelligence on/off
  -depth <int> : Algorithm minimax depth
  -background <int> <int> <int> : set background (RGB)
  -help  Display this list of options
  --help  Display this list of options
```
## More screenshots 


## TODO

	* Consideration of tactical values