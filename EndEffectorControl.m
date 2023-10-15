classdef EndEffectorControl
    % ENDEFFECTORCONTROL Class to control end effector suction
    
    properties (Constant)
        % eeService = rossvcclient('/dobot/ee_ctrl');                         % Service to control end effector suction
    end

    properties
        % eeSrvStatus = 0;                                                    % Status of end effector service initialisation
    end
    
    methods
        function self = EndEffectorControl()
            % ENDEFFECTORCONTROL Define all functions required in the class
            self.ToolState();
            self.On();
            self.Off();
        end
    end

    methods (Static)        
        function currentToolState = ToolState()
            % TOOLSTATE Check the tool state
            % Called to identify whether suction is on or off

            % Define the subscriber and output
            toolStateSubscriber = rossubscriber('/dobot_magician/tool_state');
            pause(2);
            currentToolState = toolStateSubscriber.LatestMessage.Data;
        end

        function On()
            % ON Function to turn the suction end effector on
            
            % Check tool state
            currentToolState = ToolState();

            % If tool is already on, break
            while currentToolState == 1
                break
            end

            % If tool is not on, turn suction on
            while currentToolState ~= 1
                [toolStatePub, toolStateMsg] = rospublisher('/dobot_magician/target_tool_state');
                toolStateMsg.Data = [1];
                send(toolStatePub,toolStateMsg);
            end

            pause(2);
            % Check tool state to confirm success
            currentToolState = ToolState();

            % Print confirmation to terminal
            fprintf('Suction state: %d\n',currentToolState);
        end

        function Off()
            % OFF Function to turn the suction end effector on
            
            % Check tool state
            currentToolState = ToolState();

            % If tool is already off, break
            while currentToolState ~= 1
                break
            end

            % If tool is not on, turn suction on
            while currentToolState == 1
                [toolStatePub, toolStateMsg] = rospublisher('/dobot_magician/target_tool_state');
                toolStateMsg.Data = [0];
                send(toolStatePub,toolStateMsg);
            end

            pause(2);
            % Check tool state to confirm success
            currentToolState = ToolState();

            % Print confirmation to terminal
            fprintf('Suction state: %d\n',currentToolState);
        end
    end
end

