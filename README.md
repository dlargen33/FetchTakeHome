# FetchTakeHome

### Summary: Include screen shots or a video of your app highlighting its features
This solution implements the MVVM (Model-View-ViewModel) architectural pattern with a structured, layered approach to ensure modularity, testability, and maintainability. The architecture follows a View → ViewModel → Service → Networking/Data Access flow, clearly separating concerns.

Architectural Overview:
	1.	View: Displays UI components and observes ViewModel state.
	2.	ViewModel: Contains presentation logic, interacts with the Service layer, and exposes data to the View.
	3.	Service Layer: Acts as an intermediary between the ViewModel and underlying data sources (API & local storage).
	4.	Networking & Data Access Layer: Handles API communication and Core Data persistence.

Key Features:
	•	MVVM with a Clean Service Layer: Ensures that ViewModels remain lightweight and only depend on abstracted services.
	•	Networking Integration: Fetches remote data from an API efficiently.
	•	Core Data Storage: Caches relevant data for offline access.
	•	Separation of Concerns: Each layer is responsible for a distinct function, making the codebase scalable and maintainable.

Screenshots & Demo:
<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 16px;">
  <!-- Row 1 -->
  <img src="resized_image_1.jpeg" alt="Image 1" style="width: 45%; height: auto;">
  <img src="resized_image_2.jpeg" alt="Image 2" style="width: 45%; height: auto;">
  
  <!-- Row 2 -->
  <img src="resized_image_3.jpeg" alt="Image 3" style="width: 45%; height: auto;">
  <img src="resized_image_4.jpeg" alt="Image 4" style="width: 45%; height: auto;">
</div>


### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

### Weakest Part of the Project: What do you think is the weakest part of your project?

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
