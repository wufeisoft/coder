/**
 * COPYRIGHT (C) ${year} ${company}. ALL RIGHTS RESERVED.
 *
 * No part of this publication may be reproduced, stored in a retrieval system,
 * or transmitted, on any form or by any means, electronic, mechanical, photocopying,
 * recording, or otherwise, without the prior written permission of ${company}.
 *
 * Created By: ${user}
 * Created On: ${date}
 *
 * Amendment History:
 *
 * Amended By       Amended On      Amendment Description
 * ------------     -----------     ---------------------------------------------
 *
 **/

<#assign tableField="${result.getFirstCharacterUppercase(result.getTableName())}">
<#assign tableLowercaseField="${result.getFirstCharacterLowercase(result.getTableName())}">
import React from 'react';
import ReactDOM from 'react-dom';
import { Table, Button , Row , Col ,Icon ,Form, Input ,DatePicker ,Select ,Modal } from 'antd';
import {Add${tableField} , Update${tableField}} from '../../components'
import { connect } from 'react-redux';
import * as ${tableField}Action from '../../actions/${tableField}Action';
import * as CommonAction from '../../actions/CommonAction'
import { bindActionCreators } from 'redux';
import DomUtil from '../../utils/domUtil';

const FormItem = Form.Item;
const confirm = Modal.confirm;

//定义表头
const columns = [{
        title:'序号',
        render: (text, record, index) => <span>{index+1}</span>,
        width:35
    },
<#foreach prop in result.getColumns()>
    <#if !prop.pKey>
        <#assign param="${prop.remarks}">
        <#if param == "">
            <#assign param="${result.getFirstCharacterLowercase(prop.columnName)}">
        </#if>
    {
        title: '${param}',
        dataIndex: '${result.getFirstCharacterLowercase(prop.columnName)}',
        width: 100
    },
    </#if>
</#foreach>
];

export default class ${tableField}Manager extends React.Component {
    /**
    * 构造方法 初始化数据
    * @param props
    */
    constructor(props) {
        super(props);
        //初始化bind(this)
        this.onSelectChange = this.onSelectChange.bind(this)
        this.handleSearch = this.handleSearch.bind(this);
        this.handleReset = this.handleReset.bind(this);
        this.handleDelete = this.handleDelete.bind(this);
        this.handleSave = this.handleSave.bind(this);
        this.handleUpdate = this.handleUpdate.bind(this);
        this.handleTableChange = this.handleTableChange.bind(this);
        this.handleTableSizeChange = this.handleTableSizeChange.bind(this);
        this.handleRowClick = this.handleRowClick.bind(this);
    }

    // 完成渲染新的props或者state后调用，此时可以访问到新的DOM元素。
    componentDidUpdate() {
        DomUtil.controlTable();
    }

    /**
    * 点击table第一列checkBox时调用，
    * @param selectedRowKeys 所有选中row的key的集合
    */
    onSelectChange(selectedRowKeys) {
        this.props.commonAction.setSelectedRowKeys([...selectedRowKeys]);
    }


    /**
    * 查询
    * @param e
    */
    handleSearch(e) {
        //组织表单默认提交
        e.preventDefault();
        //验证表单
        this.props.form.validateFields((errors, values) => {
            if (!!errors) {
                return;
            }
            this.props.${tableLowercaseField}Action.listPg({param:values});
        });
    }

    /**
    * 重置搜索条件
    * @param e
    */
    handleReset(e) {
        e.preventDefault();
        this.props.form.resetFields();
    }

    /**
    * 分页、排序、筛选变化时触发，向后台重新请求数据
    * @param pagination 分页器
    * @param filters
    * @param sorter
    */
    handleTableChange(pagination, filters, sorter) {
        let params = Object.assign(
            {},
            {param:this.props.form.getFieldsValue()},
            {pageNo: pagination.current,pageSize: pagination.pageSize}
        );
        this.props.${tableLowercaseField}Action.listPg(params);
    }

    /**
    * 分页组件 改变分页大小时触发，向后台重新请求数据
    * @param current  下一页
    * @param pageSize 分页大小
    */
    handleTableSizeChange(current, pageSize) {
        let params = Object.assign(
            {},
            {param:this.props.form.getFieldsValue()},
            {pageNo: current,pageSize: pageSize}
        );
        this.props.${tableLowercaseField}Action.listPg(params);
    }

    /**
    * 点击table某一行时触发，把选中的记录的主键存入store
    * @param record
    * @param index
    */
    handleRowClick(record, index) {
        this.props.commonAction.addOrDeleteSelectedRowKeys(record.resId);
    }


    /**
    * 显示弹窗
    * @param type 弹窗子组件类型
    * @param field 弹窗index [0,1,2,3,4]
    */
    showModal(type, field) {
        switch (type) {
        case 'add':
        {
            this.props.${tableLowercaseField}Action.initForm();
            break;
        }
        case 'update':
        {
            let selectedRowKeys = this.props.selectedRowKeys;
            if(selectedRowKeys.length > 1){
                Modal.error({
                    title: '只能选择一条记录!',
                    okText:'确定'
                });
                return;
            }else{
                this.props.${tableLowercaseField}Action.initForm();
                this.props.${tableLowercaseField}Action.getByPK(selectedRowKeys[0]);
            }
            break;
        }
        default:
            break;
        }
        this.props.commonAction.showModal(field);

    }

    /**
    * 关闭弹窗
    * @param field 弹窗index [0,1,2,3,4]
    */
    handleCancel(field) {
        this.props.commonAction.hideModal(field);
    }


    /**
    * 添加记录
    * @param form
    */
    handleSave(form) {
        this.props.${tableLowercaseField}Action.add(form,{param:this.props.form.getFieldsValue()});
    }

    /**
    * 更新记录
    * @param form
    */
    handleUpdate(form){
        this.props.${tableLowercaseField}Action.update(form ,{param:this.props.form.getFieldsValue()});
    }

    /**
    * 删除选中记录
    * @param e
    */
    handleDelete(e) {
        e.preventDefault();
        let selectedRowKeys = this.props.selectedRowKeys;
        let params = {param:this.props.form.getFieldsValue()};
        let _this = this;
        if (selectedRowKeys.length != 0) {
            confirm({
                title: '您是否确认要删除所选记录?',
                onOk() {
                _this.props.${tableLowercaseField}Action.deleteByPks(selectedRowKeys,params);
                }
            });
        }
    }


    /**
    * 组件渲染完成后触发
    */
    componentDidMount() {
        //初始化弹窗状态
        this.props.commonAction.initModal();
        //初始化table选中状态
        this.props.commonAction.initSelectedKeys();
        //加载表单数据
        this.props.${tableLowercaseField}Action.listPg({param:this.props.form.getFieldsValue()});
    };

    /**
    * 渲染组件
    * @returns {XML}
    */
    render() {
        //设置搜索区域输入框大小
        const formItemLayout = {
            labelCol: {span: 10},
            wrapperCol: {span: 14},
        };
        //获取prop中需要的属性
        const { selectedRowKeys,modalVisiable,pgList,singleResult,initForm} = this.props;
        //selectedRowKeys：选中row的集合，onChange：勾选checkBox时触发
        const rowSelection = {
            selectedRowKeys,
            onChange: this.onSelectChange,
        };

        //定义分页属性
        const pagination = {
            total: pgList.total,
            current: pgList.pageNo,
            showSizeChanger: true,
            onShowSizeChange: this.handleTableSizeChange,
            showQuickJumper: true,
            defaultPageSize:pgList.pageSize,
            pageSize:pgList.pageSize,
            pageSizeOptions:['15', '20', '30', '40'],
            showTotal:total=>{return `共${'$'}{total}条记录`}
        };

        //是否有选中row
        const hasSelected = selectedRowKeys.length > 0;

        //获取form的getFieldProps，用来标识from组件名称
        const { getFieldProps } = this.props.form;

        return (
            <div>
                <Row type="flex">
                    <Col span="24">
                    <Button
                            type="primary"
                            size="large"
                            className="topBtn"
                            onClick={this.showModal.bind(this,'add',0)}
                    >
                        <Icon type="save"/>添加
                    </Button>
                    <Button
                            type="primary"
                            size="large"
                            className="topBtn"
                            disabled={!hasSelected}
                            onClick={this.showModal.bind(this,'update',1)}
                    >
                        <Icon type="edit"/>修改
                    </Button>
                    <Button
                            type="primary"
                            size="large"
                            className="topBtn"
                            disabled={!hasSelected}
                            onClick={this.handleDelete}
                    >
                        <Icon type="delete"/>删除
                    </Button>
                    </Col>
                </Row>
                <Form inline className="advanced-search-form" onSubmit={this.handleSearch} form={this.props.form}>
                    <Row type="flex">
                        <Col span="24">
                <#assign pkeyName="">
                <#foreach prop in result.getColumns()>
                    <#if !prop.pKey>
                        <#assign cls="Input">
                        <#assign param="${prop.remarks}">
                        <#if "DATE" == prop.jdbcTypeName || "TIME" == prop.jdbcTypeName || "TIMESTAMP" == prop.jdbcTypeName>
                            <#assign cls="DatePicker">
                        <#elseif "java.lang.Long" == prop.columnType || "java.lang.Integer" == prop.columnType>
                            <#assign cls="Input">
                        <#elseif "java.math.BigDecimal" == prop.columnType>
                            <#assign cls="Input">
                        </#if>
                        <#if param == "">
                            <#assign param="${result.getFirstCharacterLowercase(prop.columnName)}">
                        </#if>
                        <FormItem
                                {...formItemLayout}
                                label="${param}："
                        >
                            <${cls} {...getFieldProps('${result.getFirstCharacterLowercase(prop.columnName)}')} />
                        </FormItem>
                    <#else>
                        <#assign pkeyName="${result.getFirstCharacterLowercase(prop.columnName)}">
                    </#if>
                </#foreach>
                        </Col>
                    </Row>
                    <Row>
                        <Col span="8" offset="16" style={{ textAlign: 'right' }}>
                        <Button type="primary" htmlType="submit" className="topBtn"><Icon type="search"/>搜索</Button>
                        <Button type="ghost" className="topBtn" onClick={this.handleReset}>清除</Button>
                        </Col>
                    </Row>
                </Form>


                <Row>
                    <Col span="24">
                    <Table
                        className="twoShort"
                        rowKey = {record  => record.${pkeyName}}
                        columns={columns}
                        rowSelection={rowSelection}
                        onChange={this.handleTableChange}
                        onRowClick={this.handleRowClick}
                        dataSource={pgList.resultList}
                        useFixedHeader
                        bordered
                        pagination={pagination}
                    />
                    </Col>
                </Row>

                <Modal
                        title="添加"
                        visible={modalVisiable[0]}
                        onCancel={this.handleCancel.bind(this,0)}
                        footer={false}
                >
                    <Add${tableField} handleSave={form => this.handleSave(form)} initForm={initForm}/>
                </Modal>

                <Modal
                        title="修改"
                        visible={modalVisiable[1]}
                        onCancel={this.handleCancel.bind(this,1)}
                        footer={false}
                >
                    <Update${tableField} handleUpdate={form => this.handleUpdate(form)} singleResult={singleResult} initForm={initForm}/>
                </Modal>

            </div>
        );
    }
}

/**
* 把action操作映射到this.props中
* @param dispatch
* @returns {{${tableLowercaseField}Action: *, commonAction: *}}
*/
function dispatchToProps(dispatch) {
    return {
        ${tableLowercaseField}Action: bindActionCreators(${tableField}Action, dispatch),
        commonAction: bindActionCreators(CommonAction, dispatch),
    };
}

/**
* 把store中的属性映射到this.props中
* @param state
* @returns {{selectedRowKeys: *, modalVisiable: *, singleResult: (singleResult|*), pgList: (pgList|*), initForm: *}}
*/
function stateToProps(state) {
    return {
        selectedRowKeys: state.common.selectedRowKeys,
        modalVisiable: state.common.modalVisiable,
        singleResult:state.${tableLowercaseField}Reducer.singleResult,
        pgList : state.${tableLowercaseField}Reducer.pgList,
        initForm : state.${tableLowercaseField}Reducer.initForm,
    };
}
/**
* 获取全局路由
* @type {{router: *}}
*/
${tableField}Manager.contextTypes = {
    router: React.PropTypes.object
};

//经过 Form.create 包装的组件将会自带 this.props.form 属性
${tableField}Manager = Form.create()(${tableField}Manager)

/**
* 把action和store注入到this.props
*/
export default connect(stateToProps, dispatchToProps)(${tableField}Manager);
