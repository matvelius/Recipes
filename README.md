## Steps to Run the App

Build & run in Xcode

## Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

I prioritized the overall app architecture (making sure that there is a proper separation of concerns and modularization to ensure testability, scalability, and maintainability), while making sure the UI/UX is clean & intuitive, concurrency is handled in a logical way, and that the performance is optimized by caching the images in memory and storing them on disk when appropriate.

## Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I spent about 5 hours on this, allocating most of my time to testing (I followed TDD principles, writing the tests first, and taking them from red to green as the implementation evolved) and architecture (using protocols & dependency injection where necessary in order to avoid dependencies on concrete implementations).

## Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

The project requirements did not specify in-memory caching, however I figured this would be a good way to boost performance and decrease the amount of writing to and reading from disk. The trade-off here is a slight increase in complexity, however I think it’s worth it, given that the user can enjoy a more optimized use of network resources, faster loading of images, as well as keeping the disk use to a minimum. 

## Weakest Part of the Project: What do you think is the weakest part of your project?

Lack of UI tests and additional functionality that would be useful for a real-world recipe app, however the project description stated specifically that these are not required.

## External Code and Dependencies: Did you use any external code, libraries, or dependencies?

No, I implemented CachedAsyncImage myself (though I followed a few articles, guides, and SO discussions for inspiration) and the rest of the code uses built-in Apple APIs.

## Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

Thank you for the opportunity to submit this project! I look forward to hearing about your decision.

-----------------------

### Video:

https://drive.google.com/file/d/1NI9tUbJ1yeOBwh2hlLQv1LBIi19sYrCi/view?usp=sharing

### Screenshots:

Happy path:

![Recipe App](https://github.com/user-attachments/assets/f29bf0a1-a77d-4897-8537-77dc7d128d04)

Error View:

![Recipe App Error View](https://github.com/user-attachments/assets/377fc87c-fa18-4994-bb68-b7afa2d61935)

Empty View:

![Recipe App Empty View](https://github.com/user-attachments/assets/e9d729b2-1382-4b85-868e-f82ac761404b)
