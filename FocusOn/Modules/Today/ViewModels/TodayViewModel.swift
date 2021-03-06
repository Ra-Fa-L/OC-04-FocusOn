//
//  TodayViewModel.swift
//  FocusOn
//
//  Created by Rafal Padberg on 05.03.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import Foundation
import CoreData

class TodayViewModel {
    
    // MARK:- Public Properties
    
    weak var bindingDelegate: TodayBindingDelegate?
    var goal: Goal! {
        didSet {
            saveChanges()
        }
    }
    
    // MARK:- Private Properties
    
    private var didCheckLastGoal: Bool = false
    private var blockSaving = false
    private var coreDataLoaded: Bool = false {
        didSet {
        }
    }
    
    
    // MARK:- Initializers
    
    init(currentGoal: GoalData? = nil) {
        blockSaving = true
        if currentGoal == nil {
            self.goal = Goal()
        } else {
            
            var strings: [String] = []
            strings.append(currentGoal!.taskText1!)
            strings.append(currentGoal!.taskText2!)
            strings.append(currentGoal!.taskText3!)
            var completions: [Bool] = []
            completions.append(currentGoal!.taskCompletion1)
            completions.append(currentGoal!.taskCompletion2)
            completions.append(currentGoal!.taskCompletion3)
            
            self.goal = Goal(text: currentGoal?.goalText, completion: Int(currentGoal!.goalCompletion), date: currentGoal?.date, completions: completions, strings: strings)
            coreDataLoaded = true
        }
        blockSaving = false
    }
    
    // MARK:- Public Methods
    
    func checkLastGoalStatus() {
        if didCheckLastGoal { return }
        
        let context = AppDelegate.context
        
        if let lastGoal = GoalData.findLast(in: context) {
            let differenceOfDays = lastGoal.date?.getDifferenceOfDays(to: Date())//.addingTimeInterval(1 * 24 * 3600))
            
            switch differenceOfDays {
            case 0:
                // lastGoal is from today -> Update UI
                startNewGoal(Goal(goalData: lastGoal))
            case -1:
                // lastGoal is from yesterday -> Check if yesterday's goal is .completed
                if lastGoal.goalCompletion == 3 {
                    // lastGoal is .completed -> Start with a new goal
                    startNewGoal()
                } else {
                    // Ask User if he wants to continue with not completed goal from yesterday
                    bindingDelegate?.shouldContinueWithLastGoal(completion: { [weak self] shouldContinue in
                        
                        if shouldContinue {
                            // User wants to continue with lastGoal -> Copy last goal
                            var goal = Goal(goalData: lastGoal)
                            goal.date = Date()
                            self?.startNewGoal(goal)
                        } else {
                            // User Wants start with new goal
                            self?.startNewGoal()
                        }
                    })
                }
            default:
                // lastGoal is older than yesterday -> Start with a new goal
                startNewGoal()
            }
        } else {
            // There is no lastGoal -> Start with a new goal
            startNewGoal()
        }
        didCheckLastGoal = true
    }
    
    func changeTaskText(_ text: String, withId index: Int) {
        if text != "" {
            goal.tasks[index].fullDescription = text
        } else {
            bindingDelegate?.undoTaskTextChange(text: goal.tasks[index].fullDescription, index: index)
        }
    }
    
    func changeGoalText(_ text: String) {
        
        if text != "" {
            goal.fullDescription = text
        } else {
            bindingDelegate?.undoGoalTextChange(text: goal.fullDescription)
        }
    }
    
    func changeTaskCompletion(withId index: Int) {
        
        if goal.completion == .notYetAchieved {
            goal.completion = .completed
        }
        
        let newCompletion: Task.CompletionProgress = goal.tasks[index].completion == .notCompleted ? .completed : .notCompleted
        goal.tasks[index].completion = newCompletion
        
        updateGoalImage()
        cleanOverriddenTasks()
        bindingDelegate?.changeTask(completion: goal.tasks[index].completion, forTaskId: index)
    }
    
    func changeGoalCompletion() {
        if goal.completion == .notYetAchieved {
            
            changeGoalToNYA()
            return
        }
        
        let isCompleted = goal.completion == .completed ? true : false
        
        let from: Task.CompletionProgress = isCompleted ? .overridden : .notCompleted
        let to: Task.CompletionProgress = isCompleted ? .notCompleted : .overridden
        
        for i in 0 ..< 3 {
            if goal.tasks[i].completion == from {
                goal.tasks[i].completion = to
            }
        }
        updateGoalImage()
        bindingDelegate?.changeAllTask(completions: getTasksCompletions())
    }
    
    func changeGoalToNYA() {
        
        let progress: Goal.CompletionProgress = goal.completion == .notYetAchieved ? .completed : .notYetAchieved
        goal.completion = progress
        
        bindingDelegate?.toggleNotYetAchieved(with: goal.completion)
    }
    
    // MARK:- PRIVATE
    // MARK:- Custom Methods
    
    private func startNewGoal(_ goal: Goal? = nil) {
        self.goal = goal ?? Goal()
        updateWholeUI(animationType: (goal != nil) ? .continueWithOldGoal : .createNewGoal)
    }
    
    private func updateWholeUI(animationType: InitialAnimationType) {
        bindingDelegate?.updateWholeUI(with: self.goal, animationType: animationType)
    }
    
    private func cleanOverriddenTasks() {
        for i in 0 ..< 3 {
            if goal.tasks[i].completion == .overridden {
                goal.tasks[i].completion = .completed
            }
        }
    }
    
    private func updateGoalImage(isSwitchingNYA: Bool = false) {
        bindingDelegate?.updateGoalWith(completion: getGoalCompletion())
    }
    
    private func getGoalImageName() -> String {
        return goal.completionImageName
    }
    
    private func getGoalCompletion() -> Goal.CompletionProgress {
        return goal.completion
    }
    
    private func getTasksCompletions() -> [Task.CompletionProgress] {
        var completions = [Task.CompletionProgress]()
        goal.tasks.forEach { completions.append($0.completion) }
        return completions
    }
    
    private func getButtonsImageNames() -> [String] {
        var imageNames = [String]()
        goal.tasks.forEach { imageNames.append($0.completionImageName) }
        return imageNames
    }
    
    private func saveChanges() {
        
        if blockSaving { return }
        
        let context = AppDelegate.context
        let result = GoalData.findGoalData(matchingFromDate: Date(), in: context)
        _ = self.goal.updateOrCreateGoalData(currentData: result, in: context)
        
        do {
            try context.save()
        } catch {
            print("SAVING ERROR")
        }
    }
}
