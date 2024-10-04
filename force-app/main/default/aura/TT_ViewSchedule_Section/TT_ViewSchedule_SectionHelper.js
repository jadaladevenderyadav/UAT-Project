({
    fetchSchedule: function (component, event, helper) {
        var action = component.get('c.getTimeTableRecords');
        action.setParams({
            "i_SectionId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result) {
                    // Log each property of the result object
                    console.log('schoolName:', result.schoolName);
                    console.log('programName:', result.programName);
                    console.log('semesterName:', result.semesterName);
                    console.log('secName:', result.secName);
                    console.log('acdYear:', result.acdYear);
                    console.log('lst_Sch:', result.lst_Sch);
                    console.log('lst_TimeSlot:', result.lst_TimeSlot);
                    console.log('lst_Faculties:', result.lst_Faculties);

                    component.set("v.schoolName", result.schoolName);
                    component.set("v.programName", result.programName);
                    component.set("v.semName", result.semesterName);
                    component.set("v.secName", result.secName);
                    component.set("v.acaYear", result.acdYear);
                    component.set("v.ScheduleWrpList", result.lst_Sch);
                    component.set("v.timeSlot", result.lst_TimeSlot);
                    component.set("v.profs", result.lst_Faculties);
                } else {
                    console.error('Result is undefined or null.');
                }
            } else {
                console.error('Server call failed with state:', state);
            }
        });

        $A.enqueueAction(action);
    },
})