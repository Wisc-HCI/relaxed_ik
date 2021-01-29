import React from 'react';
import { Steps, Divider, Button } from 'antd';
import Basics from './config/Basics';
import Collision from './config/Collision';
import Behavior from './config/Behavior';
const { Step } = Steps;

class ConfigCreator extends React.Component {

  state = {step:0};

  updateUrdf = (event) => {
    this.props.onUpdate({directive:'update',config:{urdf:event.target.value}})
  }

  updateFixedFrame = (fixedFrame) => {
    this.props.onUpdate({directive:'update',config:{fixed_frame:fixedFrame}})
  }

  updateJointNames = (jointNames) => {
    this.props.onUpdate({directive:'update',config:{joint_names:jointNames}})
  }

  updateEeFixedJoints = (eeFixedJoints) => {
    this.props.onUpdate({directive:'update',config:{ee_fixed_joints:eeFixedJoints}})
  }

  updateJointOrdering = (jointOrdering) => {
    this.props.onUpdate({directive:'update',config:{joint_ordering:jointOrdering}})
  }

  updateStates = (states) => {
    this.props.onUpdate({directive:'update',config:{states:states}})
  }

  updateStartingConfig = (startingConfig) => {
    this.props.onUpdate({directive:'update',config:{starting_config:startingConfig}})
  }

  updateRobotLinkRadius = (radius) => {
    this.props.onUpdate({directive:'update',config:{robot_link_radius:radius}})
  }

  updateStaticEnvironment = (staticEnvironment) => {
    this.props.onUpdate({directive:'update',config:{static_environment:staticEnvironment}})
  }

  beginPreprocess = () => {
    //this.props.socket.emit('app_process',{action:'preprocess'})
  }

  updateObjectives = (objectives) => {
    this.props.onUpdate({directive:'update',config:{objectives:objectives}})
  }

  updateGoals = (goals) => {
    this.props.onUpdate({directive:'update',config:{goals:goals}})
  }

  updateControlMode = (mode) => {
    this.props.onUpdate({directive:'update',config:{mode_control:mode}})
  }

  updateEnvironmentMode = (mode) => {
    this.props.onUpdate({directive:'update',config:{mode_environment:mode}})
  }

  updateBaseLinkMotionBounds = (bounds) => {
    this.props.onUpdate({directive:'update',config:{base_link_motion_bounds:bounds}})
  }

  updateDisplayedState = (displayedState) => {
    this.props.onUpdate({directive:'update',meta:{displayed_state:displayedState}})
  }

  updateToManual = () => {
    this.props.onUpdate({directive:'update',meta:{control:'manual'}})
  }

  updateToSolve = () => {
    this.props.onUpdate({directive:'update',meta:{control:'solve'}})
  }

  canStep = (desired) => {
    switch (desired) {
      case 0:
        return (this.props.meta.valid_urdf && this.props.meta.valid_robot)
      case 1:
        return this.props.meta.valid_nn;
      case 2:
        return (this.props.meta.valid_config && this.props.meta.valid_solver)
    }
  }

  stepForward = () => {
    if (this.state.step+1 === 2) {
      this.updateToSolve()
    } else {
      this.updateToManual()
    }
    this.setState((state)=>({step:state.step+1}))
  }

  stepBackward = () => {
    if (this.state.step-1 === 2) {
      this.updateToSolve()
    } else {
      this.updateToManual()
    }
    this.setState((state)=>({step:state.step-1}))
  }

  getPage = () => {
    switch (this.state.step) {
      case 0:
        return (
          <Basics meta={this.props.meta}
                  config={this.props.config}
                  updateUrdf={(e)=>this.updateUrdf(e)}
                  updateFixedFrame={(e)=>this.updateFixedFrame(e)}
                  updateJointNames={(e)=>this.updateJointNames(e)}
                  updateJointOrdering={(e)=>this.updateJointOrdering(e)}
                  updateEeFixedJoints={(e)=>this.updateEeFixedJoints(e)}
                  updateControlMode={(e)=>this.updateControlMode(e)}
                  updateEnvironmentMode={(e)=>this.updateEnvironmentMode(e)}
                  />
        );
      case 1:
        return (
          <Collision meta={this.props.meta}
                     config={this.props.config}
                     updateStates={(e)=>this.updateStates(e)}
                     updateStaticEnvironment={(e)=>this.updateStaticEnvironment(e)}
                     updateRobotLinkRadius={(e)=>this.updateRobotLinkRadius(e)}
                     updateDisplayedState={(e)=>this.updateDisplayedState(e)}
                  />
        );
      case 2:
        return (
          <Behavior meta={this.props.meta}
                    config={this.props.config}
                    updateObjectives={(e)=>this.updateObjectives(e)}
                    updateGoals={(e)=>this.updateGoals(e)}
                  />
        );
      default:
        return;
    }
  }

  render() {
    return (
      <div style={{margin:10}}>
        <Steps current={this.state.step} size="large">
          <Step title="Basics" description="Specify basic robot configuration"/>
          <Step title="Collision" description="Specify how the robot may collide"/>
          <Step title="Behavior" description="Specify how the robot behaves"/>
        </Steps>
        <div style={{margin:20}}>
          {this.getPage()}
        </div>
        <Divider/>
        <div style={{display:'flex',justifyContent:'space-between'}}>
          <Button type='primary' disabled={!this.canStep(this.state.step-1)} onClick={this.stepBackward}>Previous</Button>
          <Button type='primary' disabled={!this.canStep(this.state.step+1)} onClick={this.stepForward}>Next</Button>
        </div>
      </div>
    )
  }

}

export default ConfigCreator