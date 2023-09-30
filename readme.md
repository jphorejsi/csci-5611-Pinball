Horej024@umn.edu

Code from lecture was used to make this project, no other outside sources were needed.

Features implemented: 
line segments/polygons: balls collide with triangle objects and lines acting as boarders
plunger/launcher: balls start in bottom right with a high upwards velocity simulating being hit with a launcher
Reactive obstical: the smaller blue sphere randomizes its position on the board after it gets hit
Multiple material types: most collisions will result in velocity being lost from friction but if a ball hits the
	blue sphere its velocity will be doubled.

Only the libraries included with Processing were used as thats what I programmed with

The greatest difficulty I had with the assignment was having balls collide with line segments. My first program had the balls sticking to the location where they intersected a line segment. The program could not handle the balls losing their velocity to friction. My second version worked much better but occasionally balls would phase through the line segment. The solution to this was increasing the radius of the balls.

My approach involved recycling the collision code I initially used for the first homework assignment, which was originally programmed in C++. I then adapted this code to work in Java. I built my program around the FallingBalls processing file, which was completed as part of an in-class assignment. I combined code snippets from lectures, in-class assignments, and my own implementations to successfully create my program.
To create a plunger, I relocated the spawn point of the falling balls to the lower-right corner and set their initial velocity to a high random value in the vertical (y) direction, with no horizontal (x) velocity. I introduced an integer 'id' for each collidable object to represent different material types. Just before applying velocity to the balls, I adjusted their velocity scales based on their material 'id.' For some objects, I used another form of 'id,' and if this 'id' was detected after a collision, I would randomly change the object's position. Alternatively, you could increment or decrement the position variables.

The code for ball collisions with circles or other balls was found in lecture code so implementing that was not very difficult.

All features can be show in the short clip



https://github.com/jphorejsi/csci-5611-Pinball/assets/145376083/c8162f24-b38e-48e2-96e6-6ac6d1625bfc

